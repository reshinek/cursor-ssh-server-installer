@echo off
setlocal enabledelayedexpansion

REM =========================================================
REM Cursor Remote Server Deployment Script for Windows
REM 核心功能: 获取版本、代理下载、上传部署
REM =========================================================

REM 架构配置
set REMOTE_ARCH=x64
set REMOTE_OS=linux

REM 参数解析
set PROXY_URL=http://127.0.0.1:7890
set REMOTE_TARGET=
set SSH_PORT=
set SSH_OPTS=
set SCP_OPTS=

if "%~1"=="" (
    echo 错误：缺少参数
    echo 用法: %0 [-p port] [proxy_url] remote_target
    echo   -p port: SSH端口号 ^(可选^)
    echo   proxy_url: 代理地址 ^(可选^)
    echo   remote_target: SSH目标主机 ^(必需^)
    exit /b 1
)

REM 解析参数
set arg_index=1
:parse_args
if "%~1"=="" goto args_done
if "%~1"=="-p" (
    if "%~2"=="" (
        echo 错误: -p 参数需要端口号
        exit /b 1
    )
    set SSH_PORT=%~2
    set SSH_OPTS=-p !SSH_PORT!
    set SCP_OPTS=-P !SSH_PORT!
    shift
    shift
    goto parse_args
)
if not defined REMOTE_TARGET (
    REM 检查是否是代理URL（包含http://或https://）
    echo %~1 | findstr /r "^https\?://" >nul
    if !errorlevel! equ 0 (
        set PROXY_URL=%~1
    ) else (
        set REMOTE_TARGET=%~1
    )
) else (
    REM 如果REMOTE_TARGET已设置，这应该是代理URL
    set PROXY_URL=!REMOTE_TARGET!
    set REMOTE_TARGET=%~1
)
shift
goto parse_args
:args_done

if not defined REMOTE_TARGET (
    echo 错误：必须指定远程目标主机
    exit /b 1
)

REM 检查必要命令
where cursor >nul 2>nul
if errorlevel 1 (
    echo 错误: cursor 命令未找到
    exit /b 1
)

where curl >nul 2>nul
if errorlevel 1 (
    echo 错误: curl 命令未找到
    exit /b 1
)

where scp >nul 2>nul
if errorlevel 1 (
    echo 错误: scp 命令未找到
    exit /b 1
)

where ssh >nul 2>nul
if errorlevel 1 (
    echo 错误: ssh 命令未找到
    exit /b 1
)

REM 获取Cursor版本信息
echo 获取Cursor版本信息...
for /f "tokens=*" %%i in ('cursor --version 2^>nul') do (
    if not defined CURSOR_VERSION (
        set CURSOR_VERSION=%%i
    ) else if not defined CURSOR_COMMIT (
        set CURSOR_COMMIT=%%i
    )
)

if not defined CURSOR_VERSION (
    echo 错误: 无法获取Cursor版本信息
    exit /b 1
)

echo 版本: !CURSOR_VERSION!
echo Commit: !CURSOR_COMMIT!

REM 定义路径和URL
set SCRIPT_DIR=%~dp0
set LOCAL_DOWNLOAD_DIR=%SCRIPT_DIR%cursor_downloads

REM Server文件相关
set DOWNLOAD_URL=https://cursor.blob.core.windows.net/remote-releases/!CURSOR_VERSION!-!CURSOR_COMMIT!/vscode-reh-!REMOTE_OS!-!REMOTE_ARCH!.tar.gz
set DOWNLOAD_FILENAME=cursor-server-!CURSOR_VERSION!-!CURSOR_COMMIT!-!REMOTE_OS!-!REMOTE_ARCH!.tar.gz
set REMOTE_SERVER_PATH=~/.cursor-server/cli/servers/Stable-!CURSOR_COMMIT!/server/
set REMOTE_TMP_TAR_PATH=~/.cursor-server/cursor-server.tar.gz

REM CLI文件相关
set CLI_DOWNLOAD_URL=https://cursor.blob.core.windows.net/remote-releases/!CURSOR_COMMIT!/cli-alpine-x64.tar.gz
set CLI_DOWNLOAD_FILENAME=vscode-cli-!CURSOR_COMMIT!.tar.gz
set REMOTE_CLI_PATH=~/.cursor-server/cli/servers/Stable-!CURSOR_COMMIT!/
set REMOTE_CLI_TMP_TAR_PATH=~/.cursor-server/cursor-cli.tar.gz

REM 创建本地下载目录
if not exist "%LOCAL_DOWNLOAD_DIR%" mkdir "%LOCAL_DOWNLOAD_DIR%"

REM 下载Server文件
set DOWNLOAD_PATH=%LOCAL_DOWNLOAD_DIR%\%DOWNLOAD_FILENAME%
echo ==== 下载Cursor Server ====
if exist "!DOWNLOAD_PATH!" (
    echo Server文件已存在，跳过下载: !DOWNLOAD_PATH!
) else (
    echo 开始下载Cursor Server...
    if defined PROXY_URL (
        echo 使用代理: !PROXY_URL!
        curl -L --proxy "!PROXY_URL!" "!DOWNLOAD_URL!" -o "!DOWNLOAD_PATH!"
    ) else (
        curl -L "!DOWNLOAD_URL!" -o "!DOWNLOAD_PATH!"
    )
    
    if errorlevel 1 (
        echo Server下载失败
        exit /b 1
    )
    
    echo Server下载完成
)

REM 下载CLI文件
set CLI_DOWNLOAD_PATH=%LOCAL_DOWNLOAD_DIR%\%CLI_DOWNLOAD_FILENAME%
echo ==== 下载Cursor CLI ====
if exist "!CLI_DOWNLOAD_PATH!" (
    echo CLI文件已存在，跳过下载: !CLI_DOWNLOAD_PATH!
) else (
    echo 开始下载Cursor CLI...
    if defined PROXY_URL (
        echo 使用代理: !PROXY_URL!
        curl -L --proxy "!PROXY_URL!" "!CLI_DOWNLOAD_URL!" -o "!CLI_DOWNLOAD_PATH!"
    ) else (
        curl -L "!CLI_DOWNLOAD_URL!" -o "!CLI_DOWNLOAD_PATH!"
    )
    
    if errorlevel 1 (
        echo CLI下载失败
        exit /b 1
    )
    
    echo CLI下载完成
)

REM 上传并部署
echo ==== 上传到远程服务器: !REMOTE_TARGET! ====

REM 创建远程目录
echo 创建远程目录...
ssh !SSH_OPTS! "!REMOTE_TARGET!" "mkdir -p !REMOTE_SERVER_PATH! && mkdir -p !REMOTE_CLI_PATH!"
if errorlevel 1 (
    echo 创建远程目录失败
    exit /b 1
)

REM 上传Server文件
echo 上传Server文件...
scp !SCP_OPTS! "!DOWNLOAD_PATH!" "!REMOTE_TARGET!:!REMOTE_TMP_TAR_PATH!"
if errorlevel 1 (
    echo Server文件上传失败
    exit /b 1
)

REM 上传CLI文件
echo 上传CLI文件...
scp !SCP_OPTS! "!CLI_DOWNLOAD_PATH!" "!REMOTE_TARGET!:!REMOTE_CLI_TMP_TAR_PATH!"
if errorlevel 1 (
    echo CLI文件上传失败
    exit /b 1
)

REM 远程部署Server
echo 部署Server文件...
ssh !SSH_OPTS! "!REMOTE_TARGET!" "tar -xzf !REMOTE_TMP_TAR_PATH! -C !REMOTE_SERVER_PATH! --strip-components=1 && rm !REMOTE_TMP_TAR_PATH!"
if errorlevel 1 (
    echo Server部署失败
    exit /b 1
)

REM 远程部署CLI
echo 部署CLI文件...
ssh !SSH_OPTS! "!REMOTE_TARGET!" "cd !REMOTE_CLI_PATH! && tar -xzf !REMOTE_CLI_TMP_TAR_PATH! && mv cursor cursor-!CURSOR_COMMIT! && rm !REMOTE_CLI_TMP_TAR_PATH!"
if errorlevel 1 (
    echo CLI部署失败
    exit /b 1
)

echo 部署完成！
echo 本地Server文件: !DOWNLOAD_PATH!
echo 本地CLI文件: !CLI_DOWNLOAD_PATH!
