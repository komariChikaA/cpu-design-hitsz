# HITSZ 计算机设计与实践实验指导镜像

> [!WARNING]
> 本项目及镜像资料仅供课程学习与个人研究使用，禁止传播、转载、再分发或用于商业用途。原始课程内容、图片和附件的权利归原作者及课程相关方所有；如相关权利方要求移除，将及时处理。

本仓库用于在能够访问校园内网的电脑上，抓取并保存当年《计算机设计与实践》实验指导网站：

- 当前网站：<https://cpu-design.p.cs-lab.top/>
- 往年资料参考：<https://gitee.com/hitsz-cslab/cpu>

抓取结果保存在 `mirror/`。脚本以**当前网站**为准，递归保存站内页面、图片、样式、脚本和下载附件；往年仓库只用于理解课程资料的大体组织方式。

## 推荐用法：pull 后自动同步

在 PowerShell 中运行：

```powershell
.\scripts\pull-sync.cmd
```

它依次执行：

1. `git pull`；
2. 从内网站点重新抓取完整镜像；
3. 仅当 `mirror/` 确实变化时创建提交；
4. 将当前分支推送到 `origin`。

第一次使用前，请确保 Git 已配置提交身份，并且当前电脑有 GitHub 推送权限：

```powershell
git config user.name "你的名字"
git config user.email "你的邮箱"
```

## 可选：安装 pull 后钩子

```powershell
.\scripts\install-hooks.cmd
```

安装后，只要 `git pull` 实际合并或快进了新提交，Git 的 `post-merge` hook 就会自动抓取、提交并推送。若 `git pull` 提示 Already up to date，Git 不会触发 `post-merge`；需要每次都检查网站时，请使用上面的 `pull-sync.cmd`。

钩子只对当前 clone 生效。其他电脑 clone 本仓库后也需要执行一次安装脚本。

## 只抓取，不提交

```powershell
.\scripts\sync-site.cmd
```

也可以覆盖默认参数：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync-site.ps1 `
  -BaseUri "https://cpu-design.p.cs-lab.top/" `
  -MaxFiles 5000 `
  -TimeoutSec 30
```

完整抓取成功后才会替换旧的 `mirror/`。网络中断、站点不可达或超过文件数量限制时，已有镜像不会被删除。

## 注意

- GitHub Actions 的云端机器通常无法访问校园内网站点，所以抓取在本机执行。
- 抓取无需调用 Codex 或其他大模型；静态站递归镜像更稳定，也不会产生模型调用费用。
- 请仅按课程要求使用和分享实验资料，并遵守网站及课程的相关规定。
