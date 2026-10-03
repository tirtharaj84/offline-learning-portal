# Optional advanced reverse proxy

Untested Windows example; use after direct-port Kiwix works. Back up C:\LearningPortal\runtime\nginx\conf\portal.conf. Configure Kiwix AppParameters:

```text
--port=8081 --address=127.0.0.1 --urlRootLocation=/kiwix C:\KiwixPortal\content\starter.zim
```

Inside the existing NGINX server block, add:

```nginx
location = /kiwix { return 302 /kiwix/; }
location /kiwix/ {
    proxy_pass http://127.0.0.1:8081;
    proxy_set_header Host $http_host;
}
```

No URI suffix on proxy_pass: the prefix is preserved for Kiwix. Use your actual archive name.

Validate before restarting:
```powershell
& C:\LearningPortal\runtime\nginx\nginx.exe -t -p C:/LearningPortal/runtime/nginx/ -c conf/portal.conf
```

Only after successful validation, restart OfflineLearningKiwix and OfflineLearningPortal. Add `<a href="/kiwix/">Kiwix library</a>` in the homepage. Loopback-only Kiwix needs no inbound 8081 rule: remove only OfflineLearningKiwix-HTTP if switching from direct LAN access. Test redirects, images, search and all library pages. Restore backed-up configuration/arguments if they fail. On removal, remove these locations and link, validate, then restart the portal.

References: https://kiwix-tools.readthedocs.io/en/latest/kiwix-serve.html and https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass .

Creator contact: Tirtharaj Dhungana <tirtharajdhungana84@gmail.com>.
