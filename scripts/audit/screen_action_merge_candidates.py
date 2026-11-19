"""Screen exact source formulas; semantic recommendations are authored hypotheses."""
import argparse
import json
from pathlib import Path

from rcnc.conditional_merge import canonical_action, effect_literals, fields
from rcnc.domain_building import digest, require_empty_output, save
from rcnc.pddl import parse_sexpr, typed_symbols, serialize


def screen(output):
    require_empty_output(output); output.mkdir(parents=True)
    old = Path('data/external/prospective_sources_2026_10_26_v1/ipc/files')
    new = Path('data/external/action_merge_candidates_2026_10_28_v1')
    paths = {s:Path('data/narra-domains')/(s+'_domainfile.pddl') for s in ('BIRT','SOUP','MUSI')}
    paths.update(LOGISTICS98=new/'logistics98/domain.pddl', LOGISTICS00=old/'logistics00/domain.pddl',
                 DRIVERLOG=old/'driverlog/domain.pddl', DEPOT=old/'depot/domain.pddl', ZENOTRAVEL=new/'zenotravel/domain.pddl')
    # PDDL identifiers are case-insensitive. Lowercasing here is analysis only;
    # it does not repair source files, assert admission, or alter any experiment.
    def lower(e):return [lower(x) for x in e] if isinstance(e,list) else e.lower()
    domains={s:{a[1]:a for a in lower(parse_sexpr(p.read_text(encoding='utf-8')))
                if isinstance(a,list) and a and a[0]==':action'} for s,p in paths.items()}
    pairs=[('BIRT:travel_to_trysting_place','SOUP:travel_to','priority_positive',
            'Same actor/destination/origin roles and effects; SOUP has an additional possession prerequisite.'),
           ('LOGISTICS98:drive-truck','LOGISTICS00:drive-truck','near_duplicate_control',
            'Same truck/origin/destination/city roles. Related versions are a positive engineering control, not independent family evidence.'),
           ('LOGISTICS98:fly-airplane','LOGISTICS00:fly-airplane','near_duplicate_control',
            'Same aircraft/origin/destination roles and effects; related versions, not independent families.'),
           ('LOGISTICS98:load-truck','DRIVERLOG:load-truck','priority_positive_after_admission',
            'Same package/truck/location roles and signed transfer effects; check source case normalization before compilation.'),
           ('LOGISTICS98:unload-truck','DRIVERLOG:unload-truck','priority_positive_after_admission',
            'Same package/truck/location roles and signed transfer effects; useful reversible transfer pair.'),
           ('LOGISTICS98:drive-truck','DRIVERLOG:drive-truck','participant_negative',
            'Fourth parameter is city versus driver. Equal arity/effects do not justify identifying these participants.'),
           ('DEPOT:drive','LOGISTICS98:drive-truck','unsupported_arity',
            'Three versus four parameters; current total-bijection compiler cannot merge these unchanged schemas.'),
           ('ZENOTRAVEL:fly','LOGISTICS98:fly-airplane','unsupported_arity_and_effects',
            'Fuel-level arguments and fuel consumption add effects; do not erase them to force a merge.'),
           ('MUSI:travel_together','BIRT:travel_to_trysting_place','unsupported_arity_and_effects',
            'Group travel has four actors and extra moving_towards effects, not a single-actor relocation schema.')]
    rows=[]
    for left,right,recommendation,reason in pairs:
        actions=[domains[s][n] for s,n in (r.split(':') for r in (left,right))]
        arities=[len(typed_symbols(fields(a)[':parameters'])) for a in actions]
        effects=[]
        for a in actions:
            substitutions={name:f'?p{i}' for i,name in enumerate(typed_symbols(fields(a)[':parameters']))}
            def alpha(e):
                return [alpha(x) for x in e] if isinstance(e,list) else substitutions.get(e,e)
            effects.append(effect_literals(alpha(fields(a)[':effect'])))
        rows.append({'id':left+'__'+right,'status':'screened','references':[left,right],
            'arities':arities,'same_effects_under_listed_identity_order':effects[0]==effects[1],
            'formulas':[serialize(a) for a in actions],'recommendation':recommendation,'reason':reason})
    report={'status':'complete','candidate_count':len(rows),'rows':rows,'status_counts':{'screened':len(rows)},
            'source_sha256':{p.as_posix():digest(p) for p in paths.values()},
            'implementation_sha256':digest(Path(__file__)),'model_calls':0,'planner_calls':0,
            'scope':'Read-only formula screening. Recommendations are authored hypotheses, not automatic accepted merges or independent semantic labels. Historical DRIVERLOG case mismatch and LOGISTICS00 duplicate declaration failures remain; no source repair or admission upgrade.'}
    save(output/'report.json',report)
    (output/'screen_action_merge_candidates.py').write_bytes(Path(__file__).read_bytes())
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',required=True,type=Path)
    r=screen(p.parse_args().output)
    print(json.dumps({'status':r['status'],'candidates':r['candidate_count']},indent=2))
