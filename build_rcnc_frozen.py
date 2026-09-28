"""Build and freeze a rule-generated variant set without running a planner."""
import argparse
import copy
import json
from pathlib import Path
from merge_domains import parse_domain,typed_symbols
from rcnc.protocol import ROOT,freeze_bundle


def build(folder):
    folder.mkdir(parents=True,exist_ok=True)
    if any(folder.iterdir()):raise ValueError('Use an empty bundle directory')
    possession=json.loads((ROOT/'data/rcnc/parameter_tasks_v1/consistent_constraints.json').read_text())
    witness=json.loads((ROOT/'data/rcnc/queries/lifting_smoke.json').read_text())
    registry={'version':1,'review_status':'author_hypothesis_not_independently_reviewed',
      'unreviewed_policy':'Retain source typing; absence of a registry constraint does not certify semantic adequacy.',
      'parameter_constraints':possession['parameter_constraints'],
      'interfaces':{**possession['interfaces'],**witness['interfaces']},
      'capability_definitions':{
        'footwear':'Object explicitly allowed as footwear in this authored world.',
        'wearable':'Object explicitly allowed as clothing in this authored world.',
        'key':'Object explicitly allowed to operate the key action in this authored world.',
        'portal':'Location permitted to fill the lifted portal role.',
        'guide':'Character permitted to fill the lifted guide role.',
        'standing_place':'Location permitted to fill the origin role.',
        'witness':'Character permitted to fill the lifted witness role; does not assert any event occurred.'},
      'object_profiles':{'cloak':['wearable'],'key_cloak':['key','wearable'],
                         'boots':['footwear','wearable'],'key':['key']},
      'template_queries':{'possession':possession,'witness':witness},
      'review_fields':['annotator_id','evidence_source','accept_reject_uncertain','rationale'],
      'independent_annotator_id':None}
    queue=[]
    for path in sorted((ROOT/'data/narra-domains').glob('*_domainfile.pddl')):
        domain=parse_domain(path,apply_reviewed_semantics=False);source=next(iter(domain.sources))
        for name,action in sorted(domain.actions.items()):
            params=typed_symbols(action[action.index(':parameters')+1]) if ':parameters' in action else {}
            for param,typ in params.items():
                entry=registry['parameter_constraints'].get(f'{source}:{name}',{}).get(param)
                queue.append({'source_action':f'{source}:{name}','parameter':param,'type':typ,
                    'source_file':path.relative_to(ROOT).as_posix(),
                    'status':'author_hypothesis' if entry else 'unreviewed',
                    'proposal':entry,'independent_review':None})
    registry['coverage']={'ordinary_parameter_slots':len(queue),
                          'proposed_constraints':sum(x['status']=='author_hypothesis' for x in queue),
                          'independently_reviewed':0}
    (folder/'registry.json').write_text(json.dumps(registry,indent=2)+'\n',encoding='utf-8')
    (folder/'annotation_queue.json').write_text(json.dumps(queue,indent=2)+'\n',encoding='utf-8')
    names=[]
    def save(name,q,split):
        q['evaluation_split']=split
        q['annotation_status']=registry['review_status']
        q['source_removal_scope']='all_solved'
        q['require_external_validation']=True
        q['description']='Rule-generated fixed variant. Same known source models; not a held-out domain benchmark.'
        sources=set(q['sources'])
        q['parameter_constraints']={ref:copy.deepcopy(value) for ref,value in registry['parameter_constraints'].items() if ref.split(':')[0] in sources}
        q['interfaces']={ref:copy.deepcopy(value) for ref,value in registry['interfaces'].items() if ref.split(':')[0] in sources}
        # Do not mix unrelated interface families: only preserve template-declared targets.
        targets={entry['target'] for entry in (possession if name.startswith('possession') else witness)['interfaces'].values()}
        q['interfaces']={ref:e for ref,e in q['interfaces'].items() if e['target'] in targets}
        filename=name+'.json';names.append(filename)
        (folder/filename).write_text(json.dumps(q,indent=2)+'\n',encoding='utf-8')
    for profile,caps in registry['object_profiles'].items():
        for located in (True,False):
            q=copy.deepcopy(possession)
            q['objects']['artifact']=q['objects'].pop('cloak')
            q['object_capabilities'].pop('cloak',None)
            q['object_capabilities']['artifact']=caps
            q['goal']['positive']=[[('artifact' if x=='cloak' else x) for x in fact] for fact in q['goal']['positive']]
            if not located:q['initial']=[]
            split='development' if located and profile in ('cloak','key_cloak') else 'prospective_variant'
            save(f'possession_{profile}_{"located" if located else "unlocated"}',q,split)
    for event in ('hero','helper','absent','both'):
        for colocated in (False,True):
            q=copy.deepcopy(witness);q['initial']=q['initial'][:2]
            if colocated:q['initial'][1][-1]='bench'
            for person in ('hero','helper'):
                if event in (person,'both'):q['initial'].append(['chic_np__sky_fell_on_head',person])
            split='development' if not colocated and event in ('hero','absent') else 'prospective_variant'
            save(f'witness_{event}_{"together" if colocated else "apart"}',q,split)
    manifest={'scope':'4 development anchors and 12 prospectively frozen variants from known source models; no independent-domain or independently annotated claim.',
              'tasks':names,'registry':'registry.json','annotation_queue':'annotation_queue.json',
              'generation_rules':{'possession':'4 capability profiles x presence/absence of location',
                                  'witness':'4 sky-event settings x colocated/separated initial locations'},
              'selection_policy':'All Cartesian-product variants included before any planning execution.'}
    (folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    return {'freeze_sha256':freeze_bundle(folder,manifest),'tasks':len(names),'coverage':registry['coverage']}

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    print(json.dumps(build(p.parse_args().output),indent=2))
