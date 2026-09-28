"""Explicit, evidence-labelled unary constraints on ordinary action parameters."""
import hashlib
from merge_domains import parse_domain, typed_symbols


def allowed_parameters(query, input_dir):
    from rcnc.planning import compatible
    sources=set(query.get('sources',[])) | {r.split(':')[0] for r in query.get('actions',[])}
    result={}
    for ref, entries in query.get('parameter_constraints',{}).items():
        source,action=ref.split(':',1)
        if source not in sources or any(c in source for c in '/\\.'):
            raise ValueError(f'Unknown constraint source: {ref}')
        domain=parse_domain(input_dir/f'{source}_domainfile.pddl',apply_reviewed_semantics=False)
        if action not in domain.actions:raise ValueError(f'Unknown constraint action: {ref}')
        raw=domain.actions[action]
        params=typed_symbols(raw[raw.index(':parameters')+1]) if ':parameters' in raw else {}
        result[ref]={}
        for param,entry in entries.items():
            if param not in params:raise ValueError(f'Unknown constrained parameter: {ref}:{param}')
            if not isinstance(entry,dict) or not isinstance(entry.get('evidence'),str) or not entry['evidence'].strip():
                raise ValueError(f'Constraint evidence required: {ref}:{param}')
            required=entry.get('required_capabilities',[])
            if not isinstance(required,list) or any(not isinstance(c,str) or not c for c in required):
                raise ValueError('required_capabilities must be a list of names')
            pool=entry.get('allowed_objects',list(query['objects']))
            if not isinstance(pool,list) or any(o not in query['objects'] for o in pool):
                raise ValueError(f'Unknown constraint object: {ref}:{param}')
            if 'allowed_objects' in entry and any(not compatible(query['objects'][o],params[param],domain.types) for o in pool):
                raise ValueError(f'Ill-typed constraint object: {ref}:{param}')
            allowed=[]
            for obj in pool:
                caps=query.get('object_capabilities',{}).get(obj,[])
                if not isinstance(caps,list) or any(not isinstance(c,str) for c in caps):
                    raise ValueError('object_capabilities must contain lists of names')
                if compatible(query['objects'][obj],params[param],domain.types) and set(required)<=set(caps):
                    allowed.append(obj)
            result[ref][param]=sorted(set(allowed))
    return result


def guard_name(ref,param):
    return 'rcnc_allowed_'+hashlib.sha256((ref+':'+param).encode()).hexdigest()[:16]
