"""Build a deterministic catalogue of local files. Python 3 standard library only."""
import argparse
import json
from pathlib import Path
from urllib.parse import quote

TYPES = {'.pdf':'PDF', '.mp3':'Audio', '.wav':'Audio', '.m4a':'Audio',
         '.ogg':'Audio', '.mp4':'Video', '.webm':'Video', '.html':'HTML', '.htm':'HTML'}

def build(web_root):
    web_root = Path(web_root).resolve()
    resources = web_root / 'resources'
    if not resources.is_dir():
        raise ValueError('Missing resources folder: ' + str(resources))
    records = []
    for path in sorted(resources.rglob('*'), key=lambda p: p.as_posix().casefold()):
        if not path.is_file() or path.suffix.lower() not in TYPES:
            continue
        # Skip symlinks or paths outside resources, including symlinked ancestors.
        try:
            path.resolve().relative_to(resources.resolve())
        except ValueError:
            raise ValueError('Resource resolves outside the resources folder: ' + str(path))
        if path.is_symlink():
            raise ValueError('Use real files rather than symbolic links: ' + str(path))
        sidecar = Path(str(path) + '.meta.json')
        if path.suffix.lower() in ('.html','.htm') and not sidecar.exists():
            continue  # Avoid listing every supporting HTML page in an activity.
        meta = json.loads(sidecar.read_text(encoding='utf-8-sig')) if sidecar.exists() else {}
        if not isinstance(meta, dict):
            raise ValueError('Metadata must be an object: ' + str(sidecar))
        rel = path.relative_to(web_root)
        resource_rel = path.relative_to(resources)
        default_category = resource_rel.parts[0] if len(resource_rel.parts) > 1 else 'General'
        fields = {
            'title': meta.get('title', path.stem.replace('_',' ').replace('-',' ')),
            'category': meta.get('category', default_category),
            'language': meta.get('language', 'Not recorded'),
            'source': meta.get('source', 'Not recorded'),
            'rights': meta.get('rights', 'Not recorded - check permission before sharing'),
            'description': meta.get('description',''),
        }
        if not all(isinstance(v,str) for v in fields.values()):
            raise ValueError('Metadata display fields must be text: ' + str(sidecar))
        records.append(dict(fields, type=TYPES[path.suffix.lower()],
                            url='/' + '/'.join(quote(p, safe='') for p in rel.parts)))
    return {'schema_version':1,'resources':records}

def write_catalog(web_root):
    data=build(web_root)
    target=Path(web_root)/'catalog.json'
    temp=target.with_suffix('.json.tmp')
    temp.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    temp.replace(target)
    return len(data['resources'])

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--web-root', type=Path, default=Path(__file__).resolve().parents[1]/'web')
    args=parser.parse_args()
    try:
        print('Catalogue rebuilt: %d resources.' % write_catalog(args.web_root))
    except (OSError, ValueError) as exc:
        parser.exit(1, 'Catalogue error: %s\n' % exc)
