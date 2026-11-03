"""Independent finite ground Boolean replay for saved engineering probes.

This checks physical applicability, effects and goals. It deliberately does not
reimplement Glaive intention explanation or assign semantic/narrative labels.
"""
from .pddl import parse_sexpr, section, typed_symbols


def ground(expr, bindings):
    if isinstance(expr,str):
        if expr.startswith('?') and expr not in bindings:raise ValueError('Unbound variable: '+expr)
        return bindings.get(expr,expr)
    return [ground(x,bindings) for x in expr]


def holds(expr,state):
    if not isinstance(expr,list) or not expr:raise ValueError('Unsupported Boolean expression')
    head=expr[0]
    if head=='and':return all(holds(x,state) for x in expr[1:])
    if head=='or':return any(holds(x,state) for x in expr[1:])
    if head=='not':return not holds(expr[1],state)
    if head=='=':return expr[1]==expr[2]
    if head in ('when','forall','exists','intends') or any(isinstance(x,list) for x in expr):raise ValueError('Unsupported formula')
    return tuple(expr) in state


def changes(expr,before):
    if expr[0]=='and':
        add,delete=set(),set()
        for x in expr[1:]:
            a,d=changes(x,before);add.update(a);delete.update(d)
        return add,delete
    if expr[0]=='when':return changes(expr[2],before) if holds(expr[1],before) else (set(),set())
    sign,atom=(False,expr[1]) if expr[0]=='not' else (True,expr)
    if atom[0] in ('intends','forall','exists','=','or') or any(isinstance(x,list) for x in atom):raise ValueError('Unsupported effect')
    return ({tuple(atom)},set()) if sign else (set(),{tuple(atom)})


def replay_physical(domain_path,problem_path,plan_path):
    domain=parse_sexpr(domain_path.read_text(encoding='utf-8'));problem=parse_sexpr(problem_path.read_text(encoding='utf-8'))
    plan=parse_sexpr(plan_path.read_text(encoding='utf-8'))
    if section(problem,':init') is None:raise ValueError('needs_initial_state')
    if section(plan,':problem')[1] != section(problem,'problem')[1]:raise ValueError('Plan problem mismatch')
    actions={a[1]:a for a in domain if isinstance(a,list) and a and a[0]==':action'}
    types=typed_symbols((section(domain,':types') or [':types'])[1:])
    objects={**typed_symbols((section(domain,':constants') or [':constants'])[1:]),
             **typed_symbols((section(problem,':objects') or [':objects'])[1:])}
    def compatible(actual,required):
        seen=set()
        while actual not in seen:
            if actual==required or required=='object':return True
            seen.add(actual);actual=types.get(actual,'object')
        return False
    state=set()
    for fact in section(problem,':init')[1:]:
        if fact[0]=='intends':continue
        if fact[0]=='not':raise ValueError('Explicit negative initial facts outside probe contract')
        state.add(tuple(fact))
    goal=section(problem,':goal')[1];initial_goal=holds(goal,state)
    applied=[];steps=section(plan,':steps')
    if steps is None:raise ValueError('Missing plan steps')
    for index,call in enumerate(steps[1:]):
        if call[0]=='non-executed':return {'status':'unsupported_counterfactual_plan'}
        action=actions[call[0]];fields=dict(zip(action[2::2],action[3::2]));params=typed_symbols(fields.get(':parameters',[]))
        if len(params)!=len(call)-1:raise ValueError('Action arity mismatch')
        if any(obj not in objects or not compatible(objects[obj],typ) for obj,typ in zip(call[1:],params.values())):
            raise ValueError('Ill-typed source binding')
        binding=dict(zip(params,call[1:]));pre=ground(fields.get(':precondition',['and']),binding)
        if not holds(pre,state):return {'status':'inapplicable','step':index,'applied_steps':len(applied),'initial_goal':initial_goal}
        eff=ground(fields.get(':effect',['and']),binding);add,delete=changes(eff,state)
        if add&delete:raise ValueError('Conflicting simultaneous effects')
        state=(state-delete)|add;applied.append({'action':call[0],'added':sorted(add),'deleted':sorted(delete)})
    return {'status':'replayed','steps':len(applied),'initial_goal':initial_goal,'goal':holds(goal,state),'applied':applied}
