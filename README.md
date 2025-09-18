**Read this in other languages: [English](README.md), [中文](README_zh.md).**

## Cursor Remote Server Deployment Script

### Overview
A Windows batch script that automates the deployment of Cursor remote server components to Linux servers via SSH. This script streamlines the process of setting up Cursor's remote development environment by handling downloads, uploads, and server-side deployment automatically.

### Key Features
- **Automatic Version Detection**: Retrieves local Cursor version and commit information
- **Dual File Download**: Downloads both the Cursor server and CLI components
- **Proxy Support**: Optional HTTP proxy configuration for downloads
- **SSH Port Configuration**: Support for custom SSH ports using `-p` parameter
- **Smart Caching**: Skips re-downloading files that already exist locally
- **Flexible Parameter Parsing**: Intelligent detection of proxy URLs vs. remote targets
- **Atomic Deployment**: Ensures complete deployment or rollback on failure

### Downloaded Components
1. **Cursor Server**: `vscode-reh-linux-x64.tar.gz` - The main remote server component
2. **Cursor CLI**: `cli-alpine-x64.tar.gz` - Command-line interface tools

### Usage Syntax
```cmd
installCursorSSH.bat [-p port] [proxy_url] <remote_target>
```

### Usage Examples
```cmd
# Basic deployment
installCursorSSH.bat user@server.com

# With custom SSH port
installCursorSSH.bat -p 2222 user@server.com

# With proxy
installCursorSSH.bat http://127.0.0.1:7890 user@server.com

# With both custom port and proxy
installCursorSSH.bat -p 2222 http://127.0.0.1:7890 user@server.com
```

### Prerequisites
- Windows system with batch script support
- Cursor editor installed and accessible via `cursor` command
- SSH client tools (`ssh`, `scp`) available in PATH
- `curl` command for file downloads
- Valid SSH access to target Linux server

### Deployment Process
1. **Version Detection**: Extracts Cursor version and commit hash
2. **File Download**: Downloads server and CLI archives (with optional proxy)
3. **Remote Directory Setup**: Creates necessary directories on target server
4. **File Upload**: Transfers both archives to remote server
5. **Server Deployment**: Extracts server files to correct location
6. **CLI Deployment**: Extracts and renames CLI binary with commit hash
7. **Cleanup**: Removes temporary files from remote server

### File Locations
**Local Storage**: `./cursor_downloads/`
- Server: `cursor-server-{version}-{commit}-linux-x64.tar.gz`
- CLI: `vscode-cli-{commit}.tar.gz`

**Remote Deployment**:
- Server: `~/.cursor-server/cli/servers/Stable-{commit}/server/`
- CLI: `~/.cursor-server/cli/servers/Stable-{commit}/cursor-{commit}`

### Benefits
- **Time Efficient**: Automated deployment reduces manual setup time
- **Bandwidth Optimized**: Local file caching prevents redundant downloads
- **Error Resilient**: Comprehensive error handling with meaningful messages
- **Network Flexible**: Works with corporate proxies and custom SSH configurations
- **Version Synchronized**: Ensures remote server matches local Cursor installation

This script is ideal for developers who frequently work with remote Linux servers and want to quickly set up Cursor's remote development capabilities without manual configuration.
