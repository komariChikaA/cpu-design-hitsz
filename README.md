# HITSZ 计算机设计与实践 CPU 课程设计

> [!WARNING]
> 本项目及镜像资料仅供课程学习与个人研究使用，禁止传播、转载、再分发或用于商业用途。原始课程内容、图片和附件的权利归原作者及课程相关方所有；如相关权利方要求移除，将及时处理。

## 项目简介

本仓库是《计算机设计与实践》课程的学生 CPU 实验课程设计仓库，主要用于保存和迭代 miniRV CPU 的 RTL 实现、Trace 测试、仿真波形及相关实验材料。同时，仓库也保存了课程实验指导网站的本地镜像，方便在网站无法访问时查阅实验要求、原理说明和配套附件。

仓库中的两部分内容分别是：

- **CPU 课程设计**：包含单周期 CPU 工程、A/B 组指令实现、Trace 测试脚本与报告，以及单指令 VCD 仿真波形；
- **实验指导镜像**：保存在 `mirror/`，从当前课程网站递归同步页面、图片、样式、脚本和下载附件。

课程资料来源：

- 当前网站：[https://cpu-design.p.cs-lab.top/](https://cpu-design.p.cs-lab.top/)
- 往年资料参考：[https://gitee.com/hitsz-cslab/cpu](https://gitee.com/hitsz-cslab/cpu)

镜像脚本以**当前网站**为准；往年仓库只用于理解课程资料的大体组织方式。

## 当前进度与目标

目前已完成**实验一：支持完整 miniRV 指令集的单周期 CPU**，并完成 Basic Trace 验证。现有 Trace 脚本会自动发现测试程序，当前 **45/45 项测试全部通过**；相应的单指令 VCD 波形保存在 `waveform/single/`。

下面的路线图根据实验指导书中的实验目的、实验内容和实验步骤整理：

- [x] 熟悉 miniRV 指令集、模板工程以及 CPU 的取指、译码、执行和访存过程；
- [x] 完成 A/B 组指令的数据通路与控制信号设计，整合完整单周期 CPU；
- [x] 实现支持完整 miniRV 指令集的单周期 CPU；
- [x] 使用 Basic Trace 完成单周期 CPU 功能验证，并保存单指令仿真波形；
- [ ] 将单周期 CPU 改造为至少五级流水线 CPU；
- [ ] 实现静态分支预测、流水线暂停与数据前递，解决控制冒险和数据冒险，并通过流水线 Basic Trace；
- [ ] 为 CPU 集成 ICache、DCache、AXI 总线控制器、总线桥和主存；
- [ ] 实现拨码开关、LED、数码管、UART、计时器等 I/O 接口，并通过 AXI Trace；
- [ ] 将 CPU 集成到 SoC，在 FPGA 开发板上运行 CoreMark 或 LLaMA2，并继续进行频率、访存及时序优化。

路线图依据：[实验一概述](mirror/lab1/0-overview/index.html)、[实验一步骤](mirror/lab1/12-step/index.html)、[实验二 A 概述](mirror/lab2-A/0-overview/index.html)和[实验二 B 概述](mirror/lab2-B/0-overview/index.html)。

Trace 测试、远程实验平台连接、代码上传和常见故障处理见 [Trace 测试文档](docs/TRACE_TESTING.md)。文档中的账号和密码均由使用者在运行时自行输入，仓库不会保存个人凭据。

## 新设备初始化（用户和 Agent 必读）

在 Windows 新设备上首次 clone 或打开本仓库后，必须在仓库根目录运行一次：

```powershell
.\scripts\install-hooks.cmd
```

如果 Codex 或其他自动化 Agent 读取到本 README，并且当前 clone 尚未配置 `.githooks`，Agent 应主动运行上述命令完成初始化。可用下面的命令检查是否已经配置：

```powershell
git config --get core.hooksPath
```

输出 `.githooks` 即表示已经安装，无需重复执行。该 hook 会在 `git pull` 实际更新分支后自动抓取网站；检测到镜像变化时，还会自动创建提交并推送当前分支。

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

## 按需同步课程资料

课程资料来自校内站点 [http://10.249.14.10:2012/](http://10.249.14.10:2012/)，保存在 `materials/`。每次需要更新时运行：

```powershell
.\scripts\sync-materials.cmd
```

Agent 读到“爬取课程资料”“更新课程资料”“同步 materials”等请求时，也应直接运行上述命令。
同步按需触发，不安装定时任务或后台进程。目录页会重新抓取；带有 `ETag` 或
`Last-Modified` 且未变化的大文件直接复用本地副本，避免重复下载。网络失败不会删除已有资料。

## 注意

- GitHub Actions 的云端机器通常无法访问校园内网站点，所以抓取在本机执行。
- 抓取无需调用 Codex 或其他大模型；静态站递归镜像更稳定，也不会产生模型调用费用。
- 请仅按课程要求使用和分享实验资料，并遵守网站及课程的相关规定。
