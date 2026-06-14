# ═══════════════════════════════════════════════════════════
#  E时代云剪切板 CLI 一键安装脚本 (Windows)
#  用法: irm https://code.emoera.cn/install.ps1 | iex
#  或:   powershell -ExecutionPolicy Bypass -File install.ps1
# ═══════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"

# ── 配置 ──────────────────────────────────────────────────
$NpmPackage   = "@eera/yuncode-cli"
$RepoUrl      = "https://github.com/dijkstra402/emoera-code-cli.git"
$MinNodeMajor = 18
$InstallDir   = "$env:USERPROFILE\.yuncode\cli"

# ── 颜色输出 ──────────────────────────────────────────────
function Write-Banner {
    Write-Host ""
    Write-Host "  ███████╗" -ForegroundColor DarkMagenta -NoNewline
    Write-Host "  时代云剪切板 CLI 安装程序" -ForegroundColor White
    Write-Host "  ██╔════╝" -ForegroundColor DarkMagenta -NoNewline
    Write-Host "  ─────────────────────────" -ForegroundColor DarkGray
    Write-Host "  █████╗  " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "  Terminal → Cloud" -ForegroundColor DarkGray
    Write-Host "  ██╔══╝  " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "  随时存取，一键分享" -ForegroundColor DarkGray
    Write-Host "  ███████╗" -ForegroundColor DarkMagenta -NoNewline
    Write-Host "  code.emoera.cn" -ForegroundColor DarkGray
    Write-Host "  ╚══════╝" -ForegroundColor DarkMagenta
    Write-Host ""
}

function Write-Info    { param($Msg) Write-Host "  ▸ " -ForegroundColor DarkMagenta -NoNewline; Write-Host $Msg }
function Write-Ok      { param($Msg) Write-Host "  ✓ " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-Warn    { param($Msg) Write-Host "  ⚠ " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Fail    { param($Msg) Write-Host "  ✗ " -ForegroundColor Red -NoNewline; Write-Host $Msg; exit 1 }

# ── 检查 Node.js ─────────────────────────────────────────
function Test-NodeJs {
    try {
        $nodeVersion = (node -v 2>$null)
        if (-not $nodeVersion) { return $false }
        $major = [int]($nodeVersion -replace '^v(\d+)\..*', '$1')
        if ($major -lt $MinNodeMajor) {
            Write-Fail "Node.js 版本过低: $nodeVersion（需要 v$MinNodeMajor+）"
        }
        Write-Ok "Node.js $nodeVersion"
        return $true
    } catch {
        return $false
    }
}

# ── 安装 Node.js ─────────────────────────────────────────
function Install-NodeJs {
    Write-Host ""
    Write-Warn "未检测到 Node.js"
    Write-Host "  yuncode-cli 需要 Node.js $MinNodeMajor 或更高版本" -ForegroundColor DarkGray
    Write-Host ""

    # 方式1: 尝试 winget
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    # 方式2: 尝试 choco
    $hasChoco  = Get-Command choco -ErrorAction SilentlyContinue
    # 方式3: 尝试 scoop
    $hasScoop  = Get-Command scoop -ErrorAction SilentlyContinue

    if ($hasWinget) {
        $choice = Read-Host "  检测到 winget，是否自动安装 Node.js？[Y/n]"
        if ($choice -eq "" -or $choice -match "^[Yy]") {
            Write-Info "通过 winget 安装 Node.js..."
            winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            return
        }
    }
    elseif ($hasChoco) {
        $choice = Read-Host "  检测到 Chocolatey，是否自动安装 Node.js？[Y/n]"
        if ($choice -eq "" -or $choice -match "^[Yy]") {
            Write-Info "通过 Chocolatey 安装 Node.js..."
            choco install nodejs-lts -y
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            return
        }
    }
    elseif ($hasScoop) {
        $choice = Read-Host "  检测到 Scoop，是否自动安装 Node.js？[Y/n]"
        if ($choice -eq "" -or $choice -match "^[Yy]") {
            Write-Info "通过 Scoop 安装 Node.js..."
            scoop install nodejs-lts
            return
        }
    }

    Write-Host ""
    Write-Info "请手动安装 Node.js:"
    Write-Host "  https://nodejs.org/zh-cn/download" -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  安装完成后，请重新打开终端运行此脚本" -ForegroundColor DarkGray
    Write-Host ""
    exit 0
}

# ── 检查 npm ─────────────────────────────────────────────
function Test-Npm {
    try {
        $npmVersion = (npm -v 2>$null)
        if (-not $npmVersion) { Write-Fail "未检测到 npm，请重新安装 Node.js" }
        Write-Ok "npm v$npmVersion"
        return $true
    } catch {
        Write-Fail "未检测到 npm，请重新安装 Node.js"
    }
}

# ── 安装 CLI ─────────────────────────────────────────────
function Install-Cli {
    Write-Host ""
    Write-Info "安装 yuncode-cli..."

    # 方式1: npm 全局安装
    try {
        $output = npm install -g $NpmPackage 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "通过 npm 全局安装完成"
            return
        }
    } catch {
        # 继续尝试其他方式
    }

    # 方式2: 源码安装
    Write-Warn "npm 安装失败，尝试从源码安装..."

    $hasGit = Get-Command git -ErrorAction SilentlyContinue
    if (-not $hasGit) {
        Write-Fail "需要 git 进行源码安装，请先安装 git"
    }

    # 清理旧安装
    if (Test-Path $InstallDir) {
        Remove-Item -Recurse -Force $InstallDir
    }

    Write-Info "克隆仓库..."
    git clone --depth 1 $RepoUrl $InstallDir 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "无法克隆仓库: $RepoUrl"
    }

    Push-Location $InstallDir
    try {
        Write-Info "安装依赖..."
        npm install --production 2>$null
        if ($LASTEXITCODE -ne 0) {
            npm install 2>$null
        }
    } finally {
        Pop-Location
    }

    # 创建 .cmd 启动脚本
    $binDir = "$env:USERPROFILE\.yuncode\bin"
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    }

    $cmdContent = "@echo off`nnode `"$InstallDir\bin\yuncode.js`" %*"
    Set-Content -Path "$binDir\yuncode.cmd" -Value $cmdContent -Encoding ASCII

    # 添加到用户 PATH
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$binDir*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$binDir;$userPath", "User")
        $env:Path = "$binDir;$env:Path"
        Write-Ok "已添加 $binDir 到用户 PATH"
        Write-Warn "请重新打开终端以使 PATH 生效"
    }

    Write-Ok "源码安装完成"
}

# ── 验证安装 ──────────────────────────────────────────────
function Test-Install {
    Write-Host ""

    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    try {
        $version = yuncode --version 2>$null
        if ($version) {
            Write-Ok "yuncode v$version 安装成功"
        } else {
            Write-Ok "安装完成（重新打开终端后生效）"
        }
    } catch {
        Write-Ok "安装完成（重新打开终端后生效）"
    }
}

# ── 显示后续步骤 ──────────────────────────────────────────
function Show-NextSteps {
    Write-Host ""
    Write-Host "  ────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  快速开始:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1." -ForegroundColor DarkMagenta -NoNewline
    Write-Host " 前往 " -NoNewline
    Write-Host "https://code.emoera.cn/settings" -ForegroundColor DarkMagenta -NoNewline
    Write-Host " 创建 API Token"
    Write-Host ""
    Write-Host "  2." -ForegroundColor DarkMagenta -NoNewline
    Write-Host " 配置认证:"
    Write-Host "     yuncode login" -ForegroundColor Green
    Write-Host ""
    Write-Host "  3." -ForegroundColor DarkMagenta -NoNewline
    Write-Host " 开始使用:"
    Write-Host '     yuncode push "Hello World"' -ForegroundColor Green -NoNewline
    Write-Host "    # 上传文本" -ForegroundColor DarkGray
    Write-Host '     yuncode push -f file.py' -ForegroundColor Green -NoNewline
    Write-Host "        # 上传文件" -ForegroundColor DarkGray
    Write-Host '     yuncode list' -ForegroundColor Green -NoNewline
    Write-Host "                   # 查看列表" -ForegroundColor DarkGray
    Write-Host '     yuncode pull <id>' -ForegroundColor Green -NoNewline
    Write-Host "              # 获取内容" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  文档: https://github.com/dijkstra402/emoera-code-cli" -ForegroundColor DarkGray
    Write-Host "  反馈: https://github.com/dijkstra402/emoera-code-cli/issues" -ForegroundColor DarkGray
    Write-Host ""
}

# ── 卸载功能 ──────────────────────────────────────────────
function Uninstall-Cli {
    Write-Banner
    Write-Info "卸载 yuncode-cli..."

    # 移除 npm 全局包
    try {
        $listed = npm list -g $NpmPackage 2>$null
        if ($LASTEXITCODE -eq 0) {
            npm uninstall -g $NpmPackage 2>$null
            Write-Ok "已移除 npm 全局包"
        }
    } catch {}

    # 移除源码安装
    if (Test-Path $InstallDir) {
        Remove-Item -Recurse -Force $InstallDir
        Write-Ok "已移除 $InstallDir"
    }

    # 移除 cmd 启动脚本
    $cmdFile = "$env:USERPROFILE\.yuncode\bin\yuncode.cmd"
    if (Test-Path $cmdFile) {
        Remove-Item -Force $cmdFile
        Write-Ok "已移除启动脚本"
    }

    # 移除 PATH
    $binDir = "$env:USERPROFILE\.yuncode\bin"
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -like "*$binDir*") {
        $newPath = ($userPath -split ";" | Where-Object { $_ -ne $binDir }) -join ";"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Ok "已从 PATH 移除"
    }

    Write-Host ""
    Write-Info "配置文件保留在 ~\.yuncode\config.json"
    Write-Info "如需完全移除，请运行: Remove-Item -Recurse ~\.yuncode"
    Write-Host ""

    Write-Ok "卸载完成"
}

# ── 主流程 ────────────────────────────────────────────────
function Main {
    # 支持 -Uninstall 参数
    if ($args -contains "--uninstall" -or $args -contains "uninstall") {
        Uninstall-Cli
        return
    }

    Write-Banner

    Write-Info "检测系统环境..."
    $osInfo = [System.Environment]::OSVersion
    Write-Ok "系统: Windows $($osInfo.Version)"
    Write-Host ""

    Write-Info "检查依赖..."

    # 检查 Node.js
    if (-not (Test-NodeJs)) {
        Install-NodeJs
        # 重新检查
        if (-not (Test-NodeJs)) {
            Write-Fail "Node.js 安装后仍无法检测到，请重新打开终端后重试"
        }
    }

    # 检查 npm
    Test-Npm | Out-Null

    # 安装 CLI
    Install-Cli

    # 验证安装
    Test-Install

    # 显示后续步骤
    Show-NextSteps
}

Main @args
