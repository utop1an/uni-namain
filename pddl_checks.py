"""Structural PDDL checks; no story-specific semantic rules."""
def check_domain(domain):
    from merge_domains import typed_symbols
    errors=[]
    def folded(table,label):
        out={}
        for name,value in table.items():
            key=name.lower()
            if key in out:errors.append(f'{label}: case-insensitive duplicate {name}')
            out[key]=value
        return out
    types=folded(domain.types,'type'); constants=folded(domain.constants,'constant')
    predicates=folded(domain.predicates,'predicate'); folded(domain.actions,'action')
    def valid_type(t):return t.lower()=='object' or t.lower() in types
    def compatible(actual,expected):
        actual=actual.lower();expected=expected.lower();seen=set()
        while actual not in seen:
            if actual==expected or expected=='object':return True
            seen.add(actual)
            if actual not in types:return False
            actual=types[actual].lower()
        return False
    for name,parent in types.items():
        if not valid_type(parent):errors.append(f'type {name}: unknown parent {parent}')
        seen={name};current=parent.lower()
        while current!='object' and current in types:
            if current in seen:errors.append(f'type {name}: cyclic hierarchy');break
            seen.add(current);current=types[current].lower()
    for name,t in constants.items():
        if not valid_type(t):errors.append(f'constant {name}: unknown type {t}')
    for name,pred in predicates.items():
        if name!=pred.name.lower():errors.append(f'predicate key mismatch: {name}')
        for var,t in pred.parameters:
            if not var.startswith('?') or not valid_type(t):errors.append(f'predicate {name}: invalid parameter {var}:{t}')
        if len({v.lower() for v,_ in pred.parameters})!=len(pred.parameters):errors.append(f'predicate {name}: duplicate parameters')
    def expr_check(expr,scope,label):
        if not isinstance(expr,list) or not expr or not isinstance(expr[0],str):
            errors.append(f'{label}: malformed expression');return
        head=expr[0].lower()
        if head in ('and','or','not','imply','when'):
            if head=='not' and len(expr)!=2 or head in ('imply','when') and len(expr)!=3:
                errors.append(f'{label}: malformed {head}')
            for child in expr[1:]:expr_check(child,scope,label)
            return
        if head in ('exists','forall'):
            if len(expr)!=3 or not isinstance(expr[1],list):errors.append(f'{label}: malformed quantifier');return
            local=dict(scope)
            for var,t in typed_symbols(expr[1]).items():
                if not var.startswith('?') or not valid_type(t):errors.append(f'{label}: invalid quantified variable {var}:{t}')
                local[var.lower()]=t
            expr_check(expr[2],local,label);return
        if head=='=':
            expected=['object','object']
        elif head in predicates:expected=[t for _,t in predicates[head].parameters]
        else:errors.append(f'{label}: undeclared predicate {head}');return
        if len(expr)-1!=len(expected):errors.append(f'{label}: wrong arity {head}')
        for arg,t in zip(expr[1:],expected):
            if not isinstance(arg,str):errors.append(f'{label}: unsupported term');continue
            actual=scope.get(arg.lower()) if arg.startswith('?') else constants.get(arg.lower())
            if actual is None:errors.append(f'{label}: undeclared symbol {arg}')
            elif not compatible(actual,t):errors.append(f'{label}: ill-typed {head}:{arg}:{actual}->{t}')
    for name,action in domain.actions.items():
        if len(action)<2 or action[0]!=':action' or action[1].lower()!=name.lower():
            errors.append(f'action {name}: name mismatch');continue
        if len(action[2:])%2:errors.append(f'action {name}: malformed fields');continue
        keys=action[2::2]
        if len(set(keys))!=len(keys):errors.append(f'action {name}: duplicate fields')
        if any(k not in (':parameters',':precondition',':effect') for k in keys):errors.append(f'action {name}: unsupported fields')
        raw=action[action.index(':parameters')+1] if ':parameters' in action else []
        params=typed_symbols(raw);scope={k.lower():v for k,v in params.items()}
        if len([v for v in raw if isinstance(v,str) and v.startswith('?')])!=len(scope):errors.append(f'action {name}: duplicate parameters')
        for var,t in params.items():
            if not var.startswith('?') or not valid_type(t):errors.append(f'action {name}: invalid parameter {var}:{t}')
        for key in (':precondition',':effect'):
            if key in action:expr_check(action[action.index(key)+1],scope,f'action {name} {key}')
    return sorted(set(errors))


def rename_constant(domain, old, new):
    """Rename term occurrences only; a same-spelled predicate is a different symbol."""
    from merge_domains import replace_current_name
    def rewrite(expr):
        if not isinstance(expr,list) or not expr:return expr
        head=expr[0]
        if head in ('and','or','not','imply','when'):return [head,*[rewrite(x) for x in expr[1:]]]
        if head in ('forall','exists'):return [head,expr[1],rewrite(expr[2])]
        return [head,*[new if isinstance(x,str) and x.lower()==old.lower() else x for x in expr[1:]]]
    for action in domain.actions.values():
        for key in (':precondition',':effect'):
            if key in action:action[action.index(key)+1]=rewrite(action[action.index(key)+1])
    domain.constants[new]=domain.constants.pop(old)
    replace_current_name(domain.constant_maps,old,new)


def safe_name(base,occupied):
    occupied={n.lower() for n in occupied};candidate=base.lower();i=1
    while candidate in occupied:candidate=f'{base.lower()}_{i}';i+=1
    return candidate
