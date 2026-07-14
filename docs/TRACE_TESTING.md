# Trace 测试与远程实验平台使用说明

本文整理 2026 夏季实验指导镜像中的 Trace 测试流程。请以课程网站和教师最新通知为准。

## 1. 是否必须安装虚拟机

Trace 测试需要 Linux 环境，但不强制使用本地虚拟机，可选择：

1. 连接课程远程实验平台；
2. 使用实验室提供的 WSL2 环境；
3. 自行准备 WSL、Linux 虚拟机或 Linux 电脑。

如果全程使用远程平台，本机无需安装 WSL2 或其他虚拟机，只需 SSH/SFTP 客户端和校园网连接。

## 2. 远程平台连接信息

- 主机：`10.249.12.98`
- SSH 端口：`6666`
- 用户名：运行时输入自己的学号
- 初始密码：按课程平台说明输入；首次登录后应及时修改

禁止把学号、密码、Token 或私钥写进仓库、脚本、命令示例和提交记录。本仓库不会保存或自动上传登录凭据。

在 PowerShell、Windows Terminal 或其他终端中连接：

```powershell
ssh <你的学号>@10.249.12.98 -p 6666
```

也可以使用 MobaXterm 新建 SSH Session，并填写相同的主机、端口和自己的用户名。使用结束后执行：

```bash
exit
```

远程平台有多个计算节点，每次登录到的节点可能不同，但用户文件应保持一致。平台资源有限，应尽量避开课程上课时段。

## 3. 连接诊断

先检查端口是否可达：

```powershell
Test-NetConnection 10.249.12.98 -Port 6666
```

`TcpTestSucceeded` 为 `True` 表示网络和 SSH 端口可达，但不代表账号密码一定正确。然后使用 SSH 手动登录：

```powershell
ssh -v <你的学号>@10.249.12.98 -p 6666
```

常见问题：

- 连接超时：确认已连接校园网或学校 VPN，并检查端口是否为 `6666`；
- `Permission denied (publickey,password)`：确认使用自己的学号和当前密码；若初始密码也失败，联系助教确认账号是否已开通；
- 主机密钥发生变化：不要直接忽略警告，先向教师或助教核对平台密钥；
- 登录卡顿：避开上课高峰，或改用本地 WSL/Linux 环境。

不要使用 `-p password`、把密码传入命令行，或把密码写进自动化脚本。

## 4. 获取 Trace 测试框架

登录 Linux 环境后，miniRV 使用：

```bash
cd ~
git clone https://gitee.com/hitsz-cslab/cdp-tests.git
cd cdp-tests
```

miniLA 使用：

```bash
cd ~
git clone -b miniLA https://gitee.com/hitsz-cslab/cdp-tests.git
cd cdp-tests
```

如果目录已经存在，应先确认其中是否有自己的未提交修改，再决定是否执行 `git pull`，不要直接删除目录。

## 5. 上传待测 CPU 代码

将 Vivado 工程 `src/rtl` 下的 HDL 源文件上传到远程平台的 `cdp-tests/mySoC/`：

- 上传 Verilog/SystemVerilog 源码和必要的 `.vh` 头文件；
- 不要上传 Vivado IP 目录或 IP 核生成文件；
- 不要修改或删除 `RUN_TRACE` 相关代码；
- 不要修改带有 `/* verilator public */` 的声明和注释；
- 保持课程要求的 SoC、`cpu_top`、`cpu_core` 模块层次、实例名和接口。

可以使用 MobaXterm 的 SFTP 面板上传，也可以使用 `scp`：

```powershell
scp -P 6666 -r <本地rtl目录>\* <你的学号>@10.249.12.98:~/cdp-tests/mySoC/
```

执行前请再次确认本地目录和远程目标目录，避免覆盖错误位置。

## 6. 编译和运行测试

在远程终端进入测试框架：

```bash
cd ~/cdp-tests
make
```

运行单条指令测试，例如：

```bash
make run TEST=sltu
```

出现 `Test Point Pass` 表示该测试点通过。批量运行全部测试：

```bash
python3 run_all_tests.py
```

测试结束后，根据输出的未通过测试名称，结合以下内容调试：

- `waveform/` 下生成的 `.vcd` 波形；
- `asm/` 下对应测试的反汇编文件；
- Trace 输出中的参考值与 CPU 实际值。

指导站页面中曾有“24 条必做和 13 条选做”的注释内容，但它当前被 HTML 注释隐藏，不能据此认定为今年的评分或加分规则。应以教师发布的正式要求为准。

## 7. 相关镜像页面

- `mirror/trace/trace/index.html`：测试框架总说明；
- `mirror/trace/remote_env/index.html`：远程平台指南；
- `mirror/trace/vm/index.html`：WSL2 虚拟机指南；
- `mirror/trace/env_diy/index.html`：自行部署 Linux 环境；
- `mirror/trace/surfer/index.html`：Surfer 波形查看指南。
