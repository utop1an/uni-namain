"""Conservative namespaced union baseline. No inferred semantic equivalences."""
from pathlib import Path
from rcnc.pddl import (
    Domain, Predicate, parse_domain, parse_sexpr, section, typed_symbols, serialize,
    validate_domain, write_domain, domain_summary,
)

from .domain_building import (
    check_raw_declarations, require_empty_output, digest, save,
    implementation_hashes, check_exported_problem,
)


def build(input_dir, output):
    require_empty_output(output)
    paths=sorted(input_dir.glob('*_domainfile.pddl'))
    if not paths:raise ValueError('No input domains')
    output.mkdir(parents=True,exist_ok=True)
    merged=Domain('narrative_union',set(),{},{},{},{},set())
    namespaces={};hashes={}
    for index,path in enumerate(paths):
        root=parse_sexpr(path.read_text(encoding='utf-8'))
        check_raw_declarations(root, path.name)
        allowed={'domain',':requirements',':types',':constants',':predicates',':action'}
        if any(not isinstance(part,list) or not part or part[0] not in allowed for part in root[1:]):
            raise ValueError(f'{path.name}: unsupported domain-level section')
        d=parse_domain(path)
        errors=validate_domain(d)
        if errors:raise ValueError(f'{path.name}: {errors}')
        source=next(iter(d.sources));prefix=f'd{index:03d}'
        # The implicit PDDL root is part of the source's object universe too.
        # Leaving it global changes quantified conditions and admits foreign
        # arguments after union, even when every predicate is namespaced.
        tmap={t:f'{prefix}__t_{t.lower()}' for t in d.types}
        tmap['object']=f'{prefix}__t_object'
        cmap={c:f'{prefix}__c_{c.lower()}' for c in d.constants}
        pmap={p:f'{prefix}__p_{p.lower()}' for p in d.predicates}
        amap={a:f'{prefix}__a_{a.lower()}' for a in d.actions}
        def typed(tokens):
            return [x for name,t in typed_symbols(tokens).items() for x in (name,'-',tmap.get(t,t))]
        def expr(e,objects=None):
            if not isinstance(e,list) or not e:return e
            head=e[0]
            if head in ('and','or','not','imply','when'):return [head,*[expr(x,objects) for x in e[1:]]]
            if head in ('forall','exists'):return [head,typed(e[1]),expr(e[2],objects)]
            terms={**cmap,**(objects or {})}
            return [pmap.get(head,head),*[terms.get(x,x) if isinstance(x,str) else expr(x,objects) for x in e[1:]]]
        merged.requirements.update(d.requirements);merged.sources.add(source)
        merged.types[tmap['object']]='object'
        merged.types.update({tmap[k]:tmap.get(v,v) for k,v in d.types.items()})
        merged.constants.update({cmap[k]:tmap.get(v,v) for k,v in d.constants.items()})
        merged.predicates.update({pmap[k]:Predicate(pmap[k],[(v,tmap.get(t,t)) for v,t in p.parameters]) for k,p in d.predicates.items()})
        for name,a in d.actions.items():
            b=[':action',amap[name]]
            for i in range(2,len(a),2):b.extend([a[i],typed(a[i+1]) if a[i]==':parameters' else expr(a[i+1])])
            merged.actions[amap[name]]=b
        merged.predicate_maps[source]=pmap;merged.constant_maps[source]=cmap;merged.action_maps[source]=amap
        namespaces[source]={'types':tmap,'prefix':prefix}
        hashes[path.name]=digest(path)
        problem=input_dir/f'{source}_problemfile.pddl'
        if problem.exists():
            root=parse_sexpr(problem.read_text(encoding='utf-8'))
            check_raw_declarations(root, problem.name)
            rewritten=['define',root[1]]
            objects_section=section(root,':objects') or [':objects']
            objects=typed_symbols(objects_section[1:]);omap={o:f'{prefix}__o_{o.lower()}' for o in objects}
            namespaces[source]['objects']=omap
            for part in root[2:]:
                key=part[0]
                if key==':domain':rewritten.append([key,merged.name])
                elif key==':objects':rewritten.append([key,*[x for o,t in objects.items() for x in (omap[o],'-',tmap.get(t,t))]])
                elif key in (':init',':goal'):rewritten.append([key,*[expr(x,omap) for x in part[1:]]])
                else:raise ValueError(f'Unsupported problem section: {key}')
            dest=output/'problems'/problem.name;dest.parent.mkdir(exist_ok=True)
            dest.write_text(serialize(rewritten)+'\n',encoding='utf-8')
            hashes[problem.name]=digest(problem)
    errors=validate_domain(merged)
    if errors:raise ValueError(str(errors))
    write_domain(merged,output/'meta_domain.pddl')
    rows=[]
    for problem in sorted((output/'problems').glob('*.pddl')):
        rows.append(check_exported_problem(output/'meta_domain.pddl', problem, capture_errors=True))
    info=domain_summary(merged)
    info.update(method='namespaced_union_no_semantic_merge',object_universe_policy='per_source_root_type',namespaces=namespaces,source_sha256=hashes,
                implementation_sha256=implementation_hashes([
                    Path(__file__), Path(__file__).with_name('domain_building.py'),
                    Path(__file__).with_name('pddl.py'), Path(__file__).with_name('pddl_checks.py'),
                ]))
    save(output/'meta_domain.json', info)
    report={'valid':all(r['status']=='PARSED' for r in rows),'counts':info['counts'],'problems':rows,
            'scope':'All source actions retained under injective namespaces. Independent parsing is not a plan-solvability or narrative-quality claim.'}
    save(output/'validation.json', report)
    return report
