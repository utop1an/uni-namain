"""Build a self-contained, outcome-blind human annotation page from a frozen packet."""
import argparse
import json
from pathlib import Path
from rcnc.interface_annotation import digest
from scripts.experiments.run_downward_reference import sha, save


def build(packet_path, output):
    if output.exists() and any(output.iterdir()):
        raise ValueError('Use a fresh output directory')
    packet = json.loads(packet_path.read_text(encoding='utf-8'))
    template = Path(__file__).resolve().parents[2]/'templates'/'annotation_viewer.html'
    payload = json.dumps({'packet': packet, 'packet_sha256': digest(packet)}, ensure_ascii=False).replace('<', '\\u003c').replace('&', '\\u0026')
    html = template.read_text(encoding='utf-8').replace('__PACKET_JSON__', payload)
    output.mkdir(parents=True)
    (output/'index.html').write_text(html, encoding='utf-8')
    save(output/'manifest.json', {'status': 'built', 'packet_sha256': digest(packet), 'packet_file_sha256': sha(packet_path),
        'item_count': len(packet['items']), 'html_sha256': sha(output/'index.html'), 'builder_sha256': sha(Path(__file__)),
        'template_sha256': sha(template), 'independent_labels_created': 0,
        'scope': 'Self-contained human annotation interface; no outcomes, predictions, coordinator strata, network requests or automatic labels. Browser checks do not certify semantic truth or actual independence.'})
    return output/'index.html'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--packet', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(build(args.packet, args.output))
