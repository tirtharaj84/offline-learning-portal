# Optional shelf

Save these beside the lesson index.html. Run build_media_list.py first.

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>My media shelf</title>
<link rel="stylesheet" href="style.css">
</head>
<body><main>
<h1>My media shelf</h1>
<p><a href="index.html">Back to lesson</a></p>
<ul id="list"></ul>
<p id="status" role="status">Loading...</p>
</main><script src="shelf.js"></script></body>
</html>
```

```javascript
const list = document.querySelector("#list");
const status = document.querySelector("#status");
fetch("media-list.json").then(r => {
  if (!r.ok) throw new Error("Missing list");
  return r.json();
}).then(items => {
  for (const item of items) {
    const row = document.createElement("li");
    const link = document.createElement("a");
    link.href = item.url;
    link.textContent = item.title;
    row.append(link);
    list.append(row);
  }
  status.textContent = `${items.length} files available`;
}).catch(() => {
  status.textContent = "Run build_media_list.py and reload.";
});
```

Creator contact: Tirtharaj Dhungana <tirtharajdhungana84@gmail.com>.
