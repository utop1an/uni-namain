import json
from pathlib import Path
import tempfile
import unittest

from scripts.annotation.build_annotation_viewer import build
from rcnc.interface_annotation import digest


class AnnotationViewerTests(unittest.TestCase):
    def test_embedded_packet_preserves_context_and_escapes_html_delimiters(self):
        packet = {'version': 1, 'items': [{'id': 'test', 'sides': [{'text': '</script><script>unexpected()</script>'}]}]}
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root/'packet.json'
            source.write_text(json.dumps(packet), encoding='utf-8')
            page = build(source, root/'viewer')
            html = page.read_text(encoding='utf-8')
            payload = html.split('<script type="application/json" id="payload">', 1)[1].split('</script>', 1)[0]
            self.assertEqual(json.loads(payload)['packet'], packet)
            self.assertEqual(json.loads(payload)['packet_sha256'], digest(packet))
            self.assertNotIn('</script>', payload)
            manifest = json.loads((root/'viewer/manifest.json').read_text(encoding='utf-8'))
            self.assertEqual(manifest['independent_labels_created'], 0)

    def test_existing_viewer_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root/'packet.json').write_text('{"items":[]}', encoding='utf-8')
            build(root/'packet.json', root/'viewer')
            with self.assertRaises(ValueError):
                build(root/'packet.json', root/'viewer')


if __name__ == '__main__':
    unittest.main()
