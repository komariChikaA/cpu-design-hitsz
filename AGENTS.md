# Repository instructions

## Course-material requests

When the user asks to crawl, fetch, sync, or update course materials (for example,
"爬取课程资料", "更新课程资料", "同步 materials", or "爬取 materials"), immediately run:

```powershell
.\scripts\sync-materials.cmd
```

The authoritative source is `http://10.249.14.10:2012/`, and the local destination
is `materials/`. Do not substitute the historical Gitee repository and do not probe
for a `/materials/` URL path.

After syncing, verify `materials/mirror-manifest.json`, report the downloaded file
count, and mention warnings only when they affect course files. Do not create a
scheduled task, background watcher, commit, or push unless the user explicitly asks.
