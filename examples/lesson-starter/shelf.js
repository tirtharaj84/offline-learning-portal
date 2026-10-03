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
