"""Physical replay with an explicit support gate and CWA initial-state handling."""
from .pddl import parse_sexpr, section, serialize
from .revised_probe_validation import replay_physical


class _TextProblem:
    def __init__(self,text):self.text=text
    def read_text(self,encoding):return self.text


def replay_saved(domain_path,problem_path,plan_path,*,native_axioms=False,quantified_action_effects=False):
    domain=parse_sexpr(domain_path.read_text(encoding='utf-8'))
    rule_sections={s[0] for s in domain if isinstance(s,list) and s and s[0] in (':axiom',':derived')}
    replay_axioms = rule_sections == {':axiom'} and native_axioms
    replay_quantifiers_without_axioms = not rule_sections and quantified_action_effects
    if replay_axioms or replay_quantifiers_without_axioms:
        from .glaive_intake import casefold_tree
        from .native_axiom_replay import replay_native_axioms
        problem=parse_sexpr(problem_path.read_text(encoding='utf-8'))
        plan=parse_sexpr(plan_path.read_text(encoding='utf-8'))
        return replay_native_axioms(*(casefold_tree(tree) for tree in (domain,problem,plan)),
                                    quantified_action_effects=quantified_action_effects)
    if rule_sections:
        return {'status':'unsupported','reason':'Derived predicates/axioms require a separate validator'}
    problem=parse_sexpr(problem_path.read_text(encoding='utf-8'));initial=section(problem,':init')
    if initial is None:raise ValueError('needs_initial_state')
    positive=set();negative=set();retained=[]
    for fact in initial[1:]:
        if fact[0]=='intends':retained.append(fact);continue
        atom=fact[1] if fact[0]=='not' else fact
        if not isinstance(atom,list) or not atom or atom[0] in ('intends','and','or','=','forall','exists','not') or any(isinstance(x,list) for x in atom):
            raise ValueError('Unsupported initial formula')
        if fact[0]=='not':negative.add(tuple(atom))
        else:positive.add(tuple(atom));retained.append(fact)
    if positive & negative:raise ValueError('Contradictory explicit initial facts')
    initial[:]=[':init']+retained
    # For a finite closed-world physical state, explicit negative facts equal absence.
    # Transformation is in memory; the original problem remains a hashed input.
    result=replay_physical(domain_path,_TextProblem(serialize(problem)),plan_path)
    result['explicit_negative_initial_facts']=len(negative)
    return result
