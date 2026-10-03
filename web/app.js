"use strict";
const list = document.getElementById("resources");
const search = document.getElementById("search");
const category = document.getElementById("category");
const status = document.getElementById("status");
let resources = [];
function element(tag, text, className) {const el=document.createElement(tag);el.textContent=text;if(className)el.className=className;return el;}
function localURL(url) {if(typeof url!=="string"||!url.startsWith("/")||url.startsWith("//"))throw new Error("Resource address must be local.");const u=new URL(url,window.location.origin);if(u.origin!==window.location.origin)throw new Error("Resource address must use this server.");return u.href;}
function render(){list.replaceChildren();const term=search.value.trim().toLocaleLowerCase();const selected=category.value;const shown=resources.filter(r=>(!selected||r.category===selected)&&[r.title,r.description,r.language,r.category].join(" ").toLocaleLowerCase().includes(term));status.textContent=`${shown.length} resource${shown.length===1?"":"s"}${term||selected?" matched":" available"}`;
for(const r of shown){const card=element("article","","card");card.append(element("span",r.type,"badge"),element("h2",r.title),element("p",r.description),element("p",`${r.category} · ${r.language}`,"metadata"),element("p",`Source: ${r.source}`,"metadata"),element("p",`Rights: ${r.rights}`,"metadata"));const action=element("div","","open");const link=element("a","Open resource");link.href=localURL(r.url);link.target="_blank";link.rel="noopener";action.append(link);card.append(action);list.append(card);}}
async function load(){try{const response=await fetch("catalog.json",{cache:"no-cache"});if(!response.ok)throw new Error("Catalogue unavailable.");const data=await response.json();if(data.schema_version!==1||!Array.isArray(data.resources))throw new Error("Unexpected catalogue format.");resources=data.resources;for(const r of resources){localURL(r.url);for(const k of ["title","category","type","language","source","rights","description"]){if(typeof r[k]!=="string")throw new Error("Invalid resource metadata.");}}
for(const c of [...new Set(resources.map(r=>r.category))].sort()){const option=element("option",c);option.value=c;category.append(option);}render();}catch(error){status.textContent="The catalogue could not be loaded. Open this page through the server and ask your ICT focal person to check catalog.json.";status.classList.add("error");console.error(error);}}
search.addEventListener("input",render);category.addEventListener("change",render);load();
