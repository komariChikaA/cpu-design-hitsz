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

## 当前进度与评分目标

目前已完成支持完整 miniRV 指令集的单周期 CPU、单周期 Basic/AXI Trace、
单周期 EGO1 上板，以及五级流水线 CPU 的 Basic/AXI Trace。四组 Trace 回归均为
**45/45 项通过**；相应的单指令 VCD 波形保存在 `waveform/single/`。单周期 EGO1
实板已经完成 C_TEST0～2 验证，包括 UART、拨码、LED、数码管、格式化输入输出、
递归快排、动态内存和计时器；三项均保留了独立 bitstream、Vivado 报告、串口
截图和板级照片，核验记录与可复核证据见
[`docs/course-report/`](docs/course-report/)。

课程总评由课后作业及考勤（17%）、系统实现（63%）和代码及报告（20%）组成。
本项目以系统实现达到**优秀档**为主目标，即在良好档全部完成的基础上，让
**流水线 SoC 在 FPGA 开发板上跑通 CoreMark**。

### 系统实现分档

- [X] **及格**：单周期 CPU 实现全部指令并通过 Basic Trace；理想流水线通过功能仿真；单周期 CPU 实现 AXI，并通过 `lw`、`sw` 功能仿真或 Trace。
- [X] **中等**：在及格基础上，流水线 CPU 通过 Basic Trace，单周期 CPU 通过 AXI Trace。
- [X] **良好**：在中等基础上，流水线 CPU 通过 AXI Trace，单周期 SoC 下板跑通 C_TEST 0～2。
  - [X] 流水线 AXI Trace 45/45。
  - [X] 单周期 SoC 已完成 C_TEST0（UART）实板验证。
  - [X] 单周期 SoC 已完成 C_TEST1（格式化输入输出）和 C_TEST2（递归、`malloc`、计时器）实板验证与验收记录。
- [X] **优秀**：在良好基础上，流水线 SoC 下板跑通 CoreMark。
  - [X] 完成流水线 AXI EGO1 工程的 Vivado 综合、实现、时序检查和 bitstream。
  - [X] 在 EGO1 上完成流水线 SoC 的 M 扩展、UART 和板级 I/O 基础回归。
  - [X] 在 EGO1 上稳定运行 700 次迭代 CoreMark；运行时间 32 秒，结果为
    `Correct operation validated`，得分 21.250 CoreMark、0.425 CoreMark/MHz。

### 优秀档后的加分方向

加分计入系统实现部分，该部分总分上限为 70 分。下列内容不是优秀档的前置条件：

- [ ] 实现 miniLA 指令集（系统实现部分加 6 分）；
- [ ] 增加 DDR 控制器并运行 LLAMA2；
- [X] 在流水线 EGO1 工程集成 ICache/DCache：64-line direct-mapped、
  16-byte line，支持四拍 AXI refill、write-through 和 MMIO Uncached；
- [ ] 用 Cache 版本重新完成课程 AXI Trace、Vivado 时序和实板 CoreMark，
  取得可与无 Cache 基线比较的性能结果；
- [ ] 增加矩阵键盘、VGA、以太网等外设，并编写 C 程序下板演示；
- [ ] 完成其他具有一定工作量和创新性的扩展。

当前 **miniRV + EGO1 + CoreMark** 路线已经完成优秀档实板闭环。后续工作以整理
报告、补齐仿真波形和现场验收材料为主；若时间允许，再选择 Cache、频率和访存优化
争取加分。EGO1 不以 DDR/LLAMA2 作为主线。

要求依据：[实验一概述](mirror/lab1/0-overview/index.html)、[实验一步骤](mirror/lab1/12-step/index.html)、[实验二 A 概述](mirror/lab2-A/0-overview/index.html)、[实验二 B 概述](mirror/lab2-B/0-overview/index.html)、[流水线与 SoC 理论课件](<materials/Lab2 流水线CPU及SoC设计/Theory2-PPT-流水线CPU及SoC设计.pdf>)和[联合调试课件](<materials/Lab2 流水线CPU及SoC设计/Lab2-PPT-流水线CPU与SoC设计-5（联合调试）.pdf>)。

### 后续实验基础工程

为避免流水线、AXI 和 Cache 改造相互干扰，仓库保留以下独立工程：

- `miniRV_pipeline/`：已通过 45/45 Basic Trace 的五级流水线 CPU，包含冒险处理、暂停、冲刷和数据前递；
- `miniRV_singlecycle_axi/`：已通过 AXI Trace 的单周期 AXI SoC 工程；
- `miniRV_singlecycle_axi_ego1/`：已完成 Vivado、bitstream 和 EGO1 实板验收的独立板级工程。
- `miniRV_pipeline_axi/`：已通过 45/45 AXI Trace 的无 Cache 五级流水线 AXI 工程。
- `miniRV_pipeline_axi_ego1/`：无 Cache 基线已完成流水线 M 扩展/UART/CoreMark
  实板验收；当前 Cache 版本已完成 RTL、本地/服务器 Icarus 回归和课程 AXI Trace
  45/45，等待重新跑 Vivado 时序和实板 CoreMark。
- `docs/course-report/`：保存最终实验报告、可编辑数据通路图、VCD、板级照片和
  Vivado 原始报告；不保存可重新生成的 bitstream。

当前单周期 AXI/EGO1 C_TEST0～2、流水线 Basic Trace 和流水线 AXI Trace 均已
完成；流水线 AXI/EGO1 也已完成 Vivado、时序、UART/M 扩展和 CoreMark 实板回归，
系统实现达到优秀档。当前在不改变五级流水线功能的前提下继续完成 ICache/DCache
加分项；Cache 的本地定向测试和课程 AXI Trace 45/45 已通过，但必须等新版本
Vivado 时序和实板结果后，才能声称 Cache 版本完成板级闭环。具体边界见各工程内的
`README.md`。

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
