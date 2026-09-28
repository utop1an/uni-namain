"""Conservative namespaced union baseline. No inferred semantic equivalences."""
import argparse
import hashlib
import json
from pathlib import Path
from merge_domains import Domain, Predicate, parse_domain, parse_sexpr, section, typed_symbols, serialize, validate_domain, write_domain, domain_summary
from unified_planning.io import PDDLReader


def build(input_dir, output):
    if output.exists() and any(output.iterdir()):raise ValueError('Use an empty output directory')
    paths=sorted(input_dir.glob('*_domainfile.pddl'))
    if not paths:raise ValueError('No input domains')
    output.mkdir(parents=True,exist_ok=True)
    merged=Domain('narrative_union',set(),{},{},{},{},set())
    namespaces={};hashes={}
    for index,path in enumerate(paths):
        root=parse_sexpr(path.read_text(encoding='utf-8'))
        allowed={'domain',':requirements',':types',':constants',':predicates',':action'}
        if any(not isinstance(part,list) or not part or part[0] not in allowed for part in root[1:]):
            raise ValueError(f'{path.name}: unsupported domain-level section')
        d=parse_domain(path,apply_reviewed_semantics=False)
        errors=validate_domain(d)
        if errors:raise ValueError(f'{path.name}: {errors}')
        source=next(iter(d.sources));prefix=f'd{index:03d}'
        tmap={t:f'{prefix}__t_{t.lower()}' for t in d.types}
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
        merged.types.update({tmap[k]:tmap.get(v,v) for k,v in d.types.items()})
        merged.constants.update({cmap[k]:tmap.get(v,v) for k,v in d.constants.items()})
        merged.predicates.update({pmap[k]:Predicate(pmap[k],[(v,tmap.get(t,t)) for v,t in p.parameters]) for k,p in d.predicates.items()})
        for name,a in d.actions.items():
            b=[':action',amap[name]]
            for i in range(2,len(a),2):b.extend([a[i],typed(a[i+1]) if a[i]==':parameters' else expr(a[i+1])])
            merged.actions[amap[name]]=b
        merged.predicate_maps[source]=pmap;merged.constant_maps[source]=cmap;merged.action_maps[source]=amap
        namespaces[source]={'types':tmap,'prefix':prefix}
        hashes[path.name]=hashlib.sha256(path.read_bytes()).hexdigest()
        problem=input_dir/f'{source}_problemfile.pddl'
        if problem.exists():
            root=parse_sexpr(problem.read_text(encoding='utf-8'));rewritten=['define',root[1]]
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
            hashes[problem.name]=hashlib.sha256(problem.read_bytes()).hexdigest()
    errors=validate_domain(merged)
    if errors:raise ValueError(str(errors))
    write_domain(merged,output/'meta_domain.pddl')
    rows=[]
    for problem in sorted((output/'problems').glob('*.pddl')):
        try:
            PDDLReader().parse_problem(str(output/'meta_domain.pddl'),str(problem))
            rows.append({'problem':problem.name,'status':'PARSED'})
        except Exception as exc:rows.append({'problem':problem.name,'status':'ERROR','error':str(exc)})
    info=domain_summary(merged)
    info.update(method='namespaced_union_no_semantic_merge',namespaces=namespaces,source_sha256=hashes,
                implementation_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [Path(__file__),Path(__file__).with_name('merge_domains.py'),Path(__file__).with_name('pddl_checks.py')]})
    (output/'meta_domain.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    report={'valid':all(r['status']=='PARSED' for r in rows),'counts':info['counts'],'problems':rows,
            'scope':'All source actions retained under injective namespaces. Independent parsing is not a plan-solvability or narrative-quality claim.'}
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--input',type=Path,default=Path('data/narra-domains'));p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();r=build(a.input,a.output);print(json.dumps(r,indent=2));raise SystemExit(0 if r['valid'] else 1)
