"""Physical replay with an explicit support gate and CWA initial-state handling."""
from .pddl import parse_sexpr, section, serialize
from .revised_probe_validation import replay_physical


class _TextProblem:
    def __init__(self,text):self.text=text
    def read_text(self,encoding):return self.text


def replay_saved(domain_path,problem_path,plan_path):
    domain=parse_sexpr(domain_path.read_text(encoding='utf-8'))
    if any(isinstance(s,list) and s and s[0] in (':axiom',':derived') for s in domain):
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
