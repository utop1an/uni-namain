"""Constrained source-constant lifting with query-global role assignments.

Enumerating assignments is a bounded reference strategy, not a scalable solver.
The exported parameterized PDDL uses immutable role guards; narrative initial
facts are preserved, and administrative guards are listed separately.
"""
from __future__ import annotations
import copy
import itertools
import json
from pathlib import Path
from merge_domains import parse_domain, serialize, typed_symbols
from rcnc.experiment import iter_raw_literals
from rcnc.planning import compatible, compile_query, run_query
from rcnc.validation import validate_artifacts


def role_domains(query, input_dir):
    import re
    roles = {}
    declarations = query.get('lifted_constants', {})
    if not declarations:
        raise ValueError('Expected lifted_constants declarations')
    if set(declarations) & set(query.get('constant_bindings', {})):
        raise ValueError('A source constant cannot be both fixed and lifted')
    sources = set(query.get('sources', [])) | {ref.split(':')[0] for ref in query.get('actions', [])}
    for key, entry in declarations.items():
        source, constant = key.split(':', 1)
        if source not in sources or any(x in source for x in '/\\.'):
            raise ValueError(f'Unknown source for lifted constant: {key}')
        domain = parse_domain(input_dir/f'{source}_domainfile.pddl', apply_reviewed_semantics=False)
        if constant not in domain.constants:
            raise ValueError(f'Unknown lifted constant: {key}')
        role = entry['role']
        if not re.fullmatch(r'[a-z][a-z0-9_]*', role) or not entry.get('evidence'):
            raise ValueError(f'Role name and evidence required: {key}')
        candidates = entry.get('allowed_objects', [])
        if not candidates or len(set(candidates)) != len(candidates):
            raise ValueError(f'Expected unique nonempty allowed_objects: {key}')
        required = set(entry.get('required_capabilities', []))
        for obj in candidates:
            if obj not in query['objects'] or not compatible(query['objects'][obj], domain.constants[constant], domain.types):
                raise ValueError(f'Ill-typed role candidate: {key} -> {obj}')
            capabilities = set(query.get('object_capabilities', {}).get(obj, []))
            if not required <= capabilities:
                raise ValueError(f'Missing declared capabilities: {key} -> {obj}: {sorted(required-capabilities)}')
        if role in roles:
            roles[role] &= set(candidates)
        else:
            roles[role] = set(candidates)
    for pair in query.get('distinct_roles', []):
        if len(pair) != 2 or pair[0] == pair[1] or any(role not in roles for role in pair):
            raise ValueError('distinct_roles needs pairs of different declared roles')
    return {role: sorted(values) for role,values in sorted(roles.items())}


def export_lifted(query, resolved, assignment, execution, input_dir, output):
    """Replace source constant AST occurrences, not string-matched object values."""
    output.mkdir(parents=True, exist_ok=True)
    _, initial, goal, ng, types, signatures, _ = compile_query(resolved, input_dir)
    signatures = dict(signatures)
    guards = {role:'rcnc_role_'+role for role in assignment}
    for name in guards.values():
        if name in signatures:
            raise ValueError('Reserved role predicate collision')
        signatures[name] = ('object',)
    from rcnc.constraints import allowed_parameters, guard_name
    parameter_domains = allowed_parameters(resolved, input_dir)
    capability_facts = []
    schemas = []
    schema_names = {}
    parameter_orders = {}
    metadata = []
    fixed_objects = set()
    for index, ref in enumerate(resolved['actions']):
        source, action_name = ref.split(':',1)
        domain = parse_domain(input_dir/f'{source}_domainfile.pddl',apply_reviewed_semantics=False)
        raw = domain.actions[action_name]
        params = typed_symbols(raw[raw.index(':parameters')+1]) if ':parameters' in raw else {}
        transformed = []
        action_roles = {}
        substitutions = {}
        for key in (':precondition', ':effect'):
            literals = list(iter_raw_literals(raw[raw.index(key)+1])) if key in raw else []
            group = []
            for pred,args,negated in literals:
                target = resolved.get('interfaces',{}).get(f'{source}:{pred}',{}).get('target',source.lower()+'__'+pred.lower())
                replaced=[]
                for arg in args:
                    if arg.startswith('?'):
                        replaced.append(arg)
                    elif f'{source}:{arg}' in query['lifted_constants']:
                        role=query['lifted_constants'][f'{source}:{arg}']['role']
                        variable='?lifted_'+role
                        if variable in params and role not in action_roles:
                            raise ValueError('Lifted variable collides with original parameter')
                        typ=domain.constants[arg]
                        if role in action_roles and params[variable] != typ:
                            # Same-role constants with different types in one action
                            # require explicit intersection typing, not a widened type.
                            raise ValueError('Same-role constants have different action-local types')
                        params[variable]=typ
                        action_roles[role]=variable
                        substitutions[arg]=variable
                        replaced.append(variable)
                    else:
                        obj=resolved['constant_bindings'][f'{source}:{arg}']
                        fixed_objects.add(obj)
                        substitutions[arg]=obj
                        replaced.append(obj)
                literal=[target,*replaced]
                group.append(['not',literal] if negated else literal)
            transformed.append(group)
        transformed[0].extend([guards[role],variable] for role,variable in action_roles.items())
        for param, allowed in parameter_domains.get(ref,{}).items():
            guard = guard_name(ref,param)
            if guard in signatures:
                raise ValueError('Reserved parameter-constraint predicate collision')
            signatures[guard] = ('object',)
            transformed[0].append([guard,param])
            capability_facts.extend([guard,obj] for obj in allowed)
        name=f's{index:05d}'
        schema_names[ref]=name
        parameter_orders[ref]=(list(params),action_roles)
        schemas.append([':action',name,':parameters',[x for p,t in params.items() for x in (p,'-',t)],
                        ':precondition',['and',*transformed[0]],':effect',['and',*transformed[1]]])
        metadata.append({'name':name,'source_action':ref,'parameters':params,
                         'constant_substitutions':substitutions,'role_parameters':action_roles,
                         'parameter_constraints':resolved.get('parameter_constraints',{}).get(ref,{}),
                         'allowed_parameter_objects':parameter_domains.get(ref,{})})
    domain_expr=['define',['domain','rcnc-lifted'],[':requirements',':strips',':typing',':negative-preconditions'],
                 [':types',*[x for t,parent in sorted(types.items()) for x in (t,'-',parent)]],
                 [':predicates',*[[p,*[x for i,t in enumerate(ts) for x in (f'?x{i}','-',t)]] for p,ts in sorted(signatures.items())]]]
    if fixed_objects:
        domain_expr.append([':constants',*[x for obj in sorted(fixed_objects) for x in (obj,'-',query['objects'][obj])]])
    domain_expr.extend(schemas)
    role_facts=[[guards[role],obj] for role,obj in sorted(assignment.items())]
    problem=['define',['problem','rcnc-lifted-problem'],[':domain','rcnc-lifted'],
             [':objects',*[x for obj,t in query['objects'].items() if obj not in fixed_objects for x in (obj,'-',t)]],
             [':init',*[list(f) for f in sorted(initial)],*role_facts,*capability_facts],
             [':goal',['and',*[list(f) for f in sorted(goal)],*[['not',list(f)] for f in sorted(ng)]]]]
    lines=[]
    for step in execution['validation']['trace']:
        ref=step['action'];order,action_roles=parameter_orders[ref]
        bindings=dict(step['binding'])
        bindings.update({variable:assignment[role] for role,variable in action_roles.items()})
        lines.append(serialize([schema_names[ref],*[bindings[p] for p in order]]))
    (output/'domain.pddl').write_text(serialize(domain_expr)+'\n',encoding='utf-8')
    (output/'problem.pddl').write_text(serialize(problem)+'\n',encoding='utf-8')
    (output/'plan.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    info={'schemas':metadata,'role_assignment':assignment,'administrative_initial_facts':role_facts+capability_facts,
          'narrative_initial':sorted(initial),
          'initial_projection_unchanged': initial == frozenset(tuple(f) for f in query['initial'])}
    if not info['initial_projection_unchanged']:
        raise ValueError('Narrative initial state changed during lifting')
    (output/'lifting.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return validate_artifacts(output)


def source_removal_controls(query, resolved, execution, input_dir, output):
    """Keep identical narrative init/goal while disabling each source action set."""
    from rcnc.planning import solve, replay, write_pddl
    from rcnc.selection import relevant_actions
    actions, initial, goal, ng, types, signatures, _ = compile_query(resolved,input_dir)
    rows=[]
    for source in sorted({ref.split(':')[0] for ref in resolved['actions']}):
        remaining=[a for a in actions if a.source != source]
        if query.get('selection_mode','all') == 'goal_relevance':
            remaining,_=relevant_actions(remaining,initial,goal,ng)
        status,plan,states=solve(remaining,initial,goal,ng,query.get('max_depth',10),query.get('max_states',50000))
        row={'removed_source':source,'status':status,'states':states,
             'necessary_within_fixed_assignment':True if status=='unsolvable' else False if status=='solved' else None}
        destination=output/source.lower();destination.mkdir(parents=True,exist_ok=True)
        write_pddl(destination,query,remaining,initial,goal,ng,types,signatures)
        if plan is not None:
            (destination/'plan.txt').write_text(''.join(f'({a.name})\n' for a in plan),encoding='utf-8')
            row['plan_length']=len(plan)
            row['validation']=replay(plan,initial,goal,ng)
            row['external_validation']=validate_artifacts(destination)
            if not row['validation']['valid'] or row['external_validation']['status']!='VALID':
                row['status']='validation_failed';row['necessary_within_fixed_assignment']=None
        (destination/'result.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8')
        rows.append(row)
    return rows


def run_lifted_query(query, input_dir, output):
    import hashlib
    import time
    start=time.perf_counter()
    output.mkdir(parents=True,exist_ok=True)
    if any(output.iterdir()):raise ValueError('Use an empty lifting output directory')
    (output/'query.json').write_text(json.dumps(query,indent=2)+'\n',encoding='utf-8')
    try:
        roles=role_domains(query,input_dir)
        limit=query.get('max_role_assignments',32)
        if type(limit) is not int or limit < 1:raise ValueError('Invalid max_role_assignments')
        attempts=[];best=None;exhausted=True
        # Cap candidate enumeration as well as expensive planning runs.
        for index,values in enumerate(itertools.product(*roles.values())):
            if index >= limit:
                exhausted=False
                break
            assignment=dict(zip(roles,values))
            if any(assignment[a]==assignment[b] for a,b in query.get('distinct_roles',[])):
                attempts.append({'assignment':assignment,'status':'constraint_rejected'})
                continue
            concrete=copy.deepcopy(query)
            concrete.pop('lifted_constants')
            concrete.setdefault('constant_bindings',{}).update({key:assignment[entry['role']] for key,entry in query['lifted_constants'].items()})
            case_dir=output/f'assignment_{index:03d}'
            result=run_query(concrete,input_dir,case_dir)
            row={'assignment':assignment,'status':result['status'],'plan_length':result.get('plan_length'),
                 'directory':case_dir.name,'external_validation':result.get('external_validation')}
            if result['status']=='solved':
                resolved_path=case_dir/'resolved_query.json'
                resolved=json.loads(resolved_path.read_text()) if resolved_path.exists() else concrete
                lifted_validation=export_lifted(query,resolved,assignment,result,input_dir,case_dir/'lifted')
                row['lifted_validation']=lifted_validation
                if lifted_validation['status']!='VALID':row['status']='lifted_validation_failed'
                else:
                    if query.get('source_removal_scope','best') == 'all_solved':
                        row['source_removal_controls']=source_removal_controls(query,resolved,result,input_dir,case_dir/'source_removal')
                    if best is None or result['plan_length']<best['plan_length']:best=row
            attempts.append(row)
        if best is not None and 'source_removal_controls' not in best:
            best_dir=output/best['directory']
            resolved_path=best_dir/'resolved_query.json'
            resolved=json.loads((resolved_path if resolved_path.exists() else best_dir/'query.json').read_text())
            execution=json.loads((best_dir/'result.json').read_text())
            best['source_removal_controls']=source_removal_controls(query,resolved,execution,input_dir,best_dir/'source_removal')
        complete=exhausted and all(a['status'] in {'solved','unsolvable','constraint_rejected'} for a in attempts)
        necessity=[]
        if best and query.get('source_removal_scope','best') == 'all_solved':
            sources=set(query.get('sources',[])) | {ref.split(':')[0] for ref in query.get('actions',[])}
            for source in sorted(sources):
                controls=[next((c for c in a.get('source_removal_controls',[]) if c['removed_source']==source),{}) for a in attempts]
                counterexample=any(c.get('status')=='solved' for c in controls)
                proved=exhausted and all(a['status'] in {'unsolvable','constraint_rejected'} or
                    a['status']=='solved' and c.get('status')=='unsolvable' for a,c in zip(attempts,controls))
                necessity.append({'source':source,'necessary_across_declared_assignments':False if counterexample else True if proved else None})
        result={'status':'solved' if best else ('unsolvable' if complete else 'inconclusive'),
                'assignment_space_exhausted':exhausted,'all_searches_complete':complete,
                'best':best,'attempts':attempts,'role_domains':roles,
                'source_necessity_across_assignments':necessity,
                'shortest_plan_proven_within_declared_assignment_space':bool(best) and complete}
    except (ValueError,KeyError) as exc:
        result={'status':'rejected','reason':str(exc)}
    result['elapsed_seconds']=time.perf_counter()-start
    result['query_sha256']=hashlib.sha256(json.dumps(query,sort_keys=True).encode()).hexdigest()
    result['implementation_sha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    result['scope']='Bounded global role-assignment enumeration; explicit capability claims; no inferred identity or narrative-quality guarantee.'
    (output/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result
