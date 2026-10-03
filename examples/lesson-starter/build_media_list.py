from pathlib import Path
from urllib.parse import quote
import json

folder = Path(__file__).resolve().parent
media = folder / "media"
allowed = {".pdf", ".mp3", ".wav", ".mp4", ".webm"}
items = []
for file in sorted(media.iterdir()):
    if file.is_file() and file.suffix.lower() in allowed:
        items.append({
            "title": file.stem.replace("-", " "),
            "url": "media/" + quote(file.name)
        })
(folder / "media-list.json").write_text(
    json.dumps(items, indent=2, ensure_ascii=False),
    encoding="utf-8")
print(f"Listed {len(items)} media files")
