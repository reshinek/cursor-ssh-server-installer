**其他语言版本: [English](README.md), [中文](README_zh.md).**

## Cursor 远程服务器部署脚本

### 概述
一个Windows批处理脚本，用于通过SSH自动将Cursor远程服务器组件部署到Linux服务器。该脚本通过自动处理下载、上传和服务器端部署，简化了Cursor远程开发环境的设置过程。

### 主要功能
- **自动版本检测**：获取本地Cursor版本和提交信息
- **双文件下载**：同时下载Cursor服务器和CLI组件
- **代理支持**：可选的HTTP代理配置用于下载
- **SSH端口配置**：支持使用`-p`参数自定义SSH端口
- **智能缓存**：跳过重新下载已存在的本地文件
- **灵活参数解析**：智能识别代理URL与远程目标
- **原子性部署**：确保完整部署或失败时回滚

### 下载组件
1. **Cursor服务器**：`vscode-reh-linux-x64.tar.gz` - 主要的远程服务器组件
2. **Cursor CLI**：`cli-alpine-x64.tar.gz` - 命令行界面工具

### 使用语法
```cmd
installCursorSSH.bat [-p 端口] [代理地址] <远程目标>
```

### 使用示例
```cmd
# 基本部署
installCursorSSH.bat user@server.com

# 使用自定义SSH端口
installCursorSSH.bat -p 2222 user@server.com

# 使用代理
installCursorSSH.bat http://127.0.0.1:7890 user@server.com

# 同时使用自定义端口和代理
installCursorSSH.bat -p 2222 http://127.0.0.1:7890 user@server.com
```

### 前置要求
- 支持批处理脚本的Windows系统
- 已安装Cursor编辑器并可通过`cursor`命令访问
- PATH中可用的SSH客户端工具（`ssh`、`scp`）
- 用于文件下载的`curl`命令
- 对目标Linux服务器的有效SSH访问权限

### 部署流程
1. **版本检测**：提取Cursor版本和提交哈希值
2. **文件下载**：下载服务器和CLI存档文件（可选代理）
3. **远程目录设置**：在目标服务器上创建必要目录
4. **文件上传**：将两个存档文件传输到远程服务器
5. **服务器部署**：将服务器文件解压到正确位置
6. **CLI部署**：解压并使用提交哈希重命名CLI二进制文件
7. **清理**：从远程服务器删除临时文件

### 文件位置
**本地存储**：`./cursor_downloads/`
- 服务器：`cursor-server-{版本}-{提交}-linux-x64.tar.gz`
- CLI：`vscode-cli-{提交}.tar.gz`

**远程部署**：
- 服务器：`~/.cursor-server/cli/servers/Stable-{提交}/server/`
- CLI：`~/.cursor-server/cli/servers/Stable-{提交}/cursor-{提交}`

### 优势
- **时间高效**：自动化部署减少手动设置时间
- **带宽优化**：本地文件缓存防止重复下载
- **错误恢复**：全面的错误处理和有意义的错误消息
- **网络灵活**：支持企业代理和自定义SSH配置
- **版本同步**：确保远程服务器与本地Cursor安装匹配

该脚本非常适合经常使用远程Linux服务器工作并希望快速设置Cursor远程开发功能而无需手动配置的开发者。
