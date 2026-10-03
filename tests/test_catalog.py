import importlib.util,json,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('catalog',Path(__file__).resolve().parents[1]/'scripts/generate_catalog.py')
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
class CatalogTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.res=self.root/'resources';self.res.mkdir()
 def tearDown(self):self.tmp.cleanup()
 def test_encoding_and_defaults(self):
  p=self.res/'Science'/'lesson café.pdf';p.parent.mkdir();p.write_bytes(b'sample')
  r=mod.build(self.root)['resources'][0]
  self.assertEqual(r['category'],'Science');self.assertIn('%20',r['url']);self.assertIn('%C3%A9',r['url'])
 def test_html_registration_and_unsupported(self):
  (self.res/'index.html').write_text('entry');(self.res/'helper.html').write_text('helper');(self.res/'archive.zim').write_bytes(b'zim')
  (self.res/'index.html.meta.json').write_text(json.dumps({'title':'Activity'}))
  r=mod.build(self.root)['resources'];self.assertEqual(len(r),1);self.assertEqual(r[0]['title'],'Activity')
 def test_invalid_metadata(self):
  (self.res/'a.pdf').write_bytes(b'a');(self.res/'a.pdf.meta.json').write_text('{')
  with self.assertRaises(ValueError):mod.build(self.root)
 def test_error_preserves_catalogue(self):
  target=self.root/'catalog.json';target.write_text('previous catalogue')
  (self.res/'a.pdf').write_bytes(b'a');(self.res/'a.pdf.meta.json').write_text('{')
  with self.assertRaises(ValueError):mod.write_catalog(self.root)
  self.assertEqual(target.read_text(),'previous catalogue')
 def test_symlink_outside(self):
  outside=self.root/'outside.pdf';outside.write_bytes(b'a');(self.res/'link.pdf').symlink_to(outside)
  with self.assertRaises(ValueError):mod.build(self.root)
 def test_deterministic(self):
  for name in ['z.pdf','a.pdf']:(self.res/name).write_bytes(b'a')
  self.assertEqual(mod.build(self.root),mod.build(self.root))
if __name__=='__main__':unittest.main()
