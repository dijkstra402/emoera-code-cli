#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  E时代云剪切板 CLI 一键安装脚本
#  支持: macOS / Linux (Debian/Ubuntu/CentOS/Fedora/Arch)
#  用法: curl -fsSL https://code.emoera.cn/install.sh | bash
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# ── 品牌色彩 ──────────────────────────────────────────────
PURPLE='\033[38;5;99m'
GREEN='\033[38;5;78m'
YELLOW='\033[38;5;220m'
RED='\033[38;5;203m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

REPO_URL="https://github.com/dijkstra402/emoera-code-cli.git"
NPM_PACKAGE="@eera/yuncode-cli"
MIN_NODE_VERSION=18
INSTALL_DIR="$HOME/.yuncode/cli"

# ── 辅助函数 ──────────────────────────────────────────────
banner() {
  echo ""
  echo -e "${PURPLE}  ███████╗${RESET}  ${BOLD}时代云剪切板 CLI 安装程序${RESET}"
  echo -e "${PURPLE}  ██╔════╝${RESET}  ${DIM}─────────────────────────${RESET}"
  echo -e "${PURPLE}  █████╗  ${RESET}  ${DIM}Terminal → Cloud${RESET}"
  echo -e "${PURPLE}  ██╔══╝  ${RESET}  ${DIM}随时存取，一键分享${RESET}"
  echo -e "${PURPLE}  ███████╗${RESET}  ${DIM}code.emoera.cn${RESET}"
  echo -e "${PURPLE}  ╚══════╝${RESET}"
  echo ""
}

info()    { echo -e "  ${PURPLE}▸${RESET} $1"; }
success() { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail()    { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# ── 检测操作系统 ──────────────────────────────────────────
detect_os() {
  local uname_s
  uname_s=$(uname -s)
  case "$uname_s" in
    Linux*)  OS="linux" ;;
    Darwin*) OS="macos" ;;
    *)       fail "不支持的操作系统: $uname_s" ;;
  esac
}

# ── 检测 Linux 发行版 ────────────────────────────────────
detect_distro() {
  if [ "$OS" != "linux" ]; then
    DISTRO="macos"
    return
  fi
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian|linuxmint|pop|elementary|zorin) DISTRO="debian" ;;
      centos|rhel|rocky|alma|ol)                    DISTRO="rhel" ;;
      fedora)                                        DISTRO="fedora" ;;
      arch|manjaro|endeavouros)                      DISTRO="arch" ;;
      alpine)                                        DISTRO="alpine" ;;
      opensuse*|sles)                                DISTRO="suse" ;;
      *)                                             DISTRO="unknown" ;;
    esac
  else
    DISTRO="unknown"
  fi
}

# ── 检测包管理器 ──────────────────────────────────────────
detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
  elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
  elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
  elif command -v apk &>/dev/null; then
    PKG_MANAGER="apk"
  elif command -v zypper &>/dev/null; then
    PKG_MANAGER="zypper"
  elif command -v brew &>/dev/null; then
    PKG_MANAGER="brew"
  else
    PKG_MANAGER="unknown"
  fi
}

# ── 版本号比较 ────────────────────────────────────────────
version_gte() {
  local v1="${1%%.*}"
  local v2="${2%%.*}"
  [ "$v1" -ge "$v2" ] 2>/dev/null
}

# ── 安装 Node.js ─────────────────────────────────────────
install_nodejs() {
  info "安装 Node.js..."

  case "$PKG_MANAGER" in
    brew)
      brew install node
      ;;
    apt)
      # 使用 NodeSource 仓库获取最新 LTS
      if command -v curl &>/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      elif command -v wget &>/dev/null; then
        wget -qO- https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      fi
      sudo apt-get install -y nodejs
      ;;
    dnf)
      sudo dnf module enable -y nodejs:20 2>/dev/null || true
      sudo dnf install -y nodejs npm
      ;;
    yum)
      if command -v curl &>/dev/null; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
      fi
      sudo yum install -y nodejs
      ;;
    pacman)
      sudo pacman -Sy --noconfirm nodejs npm
      ;;
    apk)
      sudo apk add --no-cache nodejs npm
      ;;
    zypper)
      sudo zypper install -y nodejs npm
      ;;
    *)
      echo ""
      warn "无法自动安装 Node.js，请手动安装:"
      echo -e "  ${DIM}https://nodejs.org/zh-cn/download${RESET}"
      echo ""
      fail "Node.js 未安装"
      ;;
  esac
}

# ── 检查 Node.js ─────────────────────────────────────────
check_nodejs() {
  if ! command -v node &>/dev/null; then
    warn "未检测到 Node.js"
    echo ""
    echo -e "  ${DIM}yuncode-cli 需要 Node.js $MIN_NODE_VERSION 或更高版本${RESET}"
    echo ""

    # 询问是否自动安装
    read -rp "  是否自动安装 Node.js？[Y/n] " answer
    answer=${answer:-Y}
    case "$answer" in
      [Yy]*)
        install_nodejs
        ;;
      *)
        echo ""
        info "请手动安装 Node.js 后重新运行此脚本:"
        echo -e "  ${DIM}https://nodejs.org/zh-cn/download${RESET}"
        echo ""
        exit 0
        ;;
    esac
  fi

  # 检查版本
  local node_version
  node_version=$(node -v | sed 's/^v//')
  if ! version_gte "$node_version" "$MIN_NODE_VERSION"; then
    fail "Node.js 版本过低: v$node_version（需要 v$MIN_NODE_VERSION+）"
  fi

  success "Node.js v$node_version"
}

# ── 检查 npm ─────────────────────────────────────────────
check_npm() {
  if ! command -v npm &>/dev/null; then
    fail "未检测到 npm，请重新安装 Node.js"
  fi
  local npm_version
  npm_version=$(npm -v)
  success "npm v$npm_version"
}

# ── 安装 CLI ─────────────────────────────────────────────
install_cli() {
  echo ""
  info "安装 yuncode-cli..."

  # 方式1: 尝试 npm 全局安装
  if npm install -g "$NPM_PACKAGE" 2>/dev/null; then
    success "通过 npm 全局安装完成"
    return 0
  fi

  # 权限不足时用 sudo 重试
  warn "全局安装需要权限提升"
  if sudo npm install -g "$NPM_PACKAGE" 2>/dev/null; then
    success "通过 npm 全局安装完成（sudo）"
    return 0
  fi

  # 方式2: 如果 npm 安装失败，用 git clone
  warn "npm 安装失败，尝试从源码安装..."

  if ! command -v git &>/dev/null; then
    fail "需要 git 进行源码安装，请先安装 git"
  fi

  # 清理旧安装
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
  fi

  git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || \
    fail "无法克隆仓库: $REPO_URL"

  cd "$INSTALL_DIR"
  npm install --production 2>/dev/null || npm install 2>/dev/null || \
    fail "npm install 失败"

  # 创建符号链接到 PATH
  local link_dir="$HOME/.local/bin"
  mkdir -p "$link_dir"
  ln -sf "$INSTALL_DIR/bin/yuncode.js" "$link_dir/yuncode"
  chmod +x "$INSTALL_DIR/bin/yuncode.js"

  # 检查 PATH
  if [[ ":$PATH:" != *":$link_dir:"* ]]; then
    warn "$link_dir 不在 PATH 中"
    echo ""

    # 自动添加到 shell 配置
    local shell_rc=""
    case "$SHELL" in
      */zsh)  shell_rc="$HOME/.zshrc" ;;
      */bash) shell_rc="$HOME/.bashrc" ;;
      *)      shell_rc="$HOME/.profile" ;;
    esac

    local path_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    if [ -f "$shell_rc" ] && ! grep -qF '.local/bin' "$shell_rc"; then
      echo "" >> "$shell_rc"
      echo "# E时代云剪切板 CLI" >> "$shell_rc"
      echo "$path_line" >> "$shell_rc"
      success "已添加 PATH 到 $shell_rc"
      warn "请运行 ${BOLD}source $shell_rc${RESET} 或重新打开终端"
    else
      echo -e "  ${DIM}请手动添加以下内容到 shell 配置文件:${RESET}"
      echo -e "  ${PURPLE}$path_line${RESET}"
    fi
  fi

  success "源码安装完成"
}

# ── 验证安装 ──────────────────────────────────────────────
verify_install() {
  echo ""
  # 重新加载 PATH
  hash -r 2>/dev/null || true

  if command -v yuncode &>/dev/null; then
    local version
    version=$(yuncode --version 2>/dev/null || echo "1.0.0")
    success "yuncode v$version 安装成功"
  else
    success "安装完成（重新打开终端后生效）"
  fi
}

# ── 显示后续步骤 ──────────────────────────────────────────
show_next_steps() {
  echo ""
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  echo ""
  echo -e "  ${BOLD}快速开始:${RESET}"
  echo ""
  echo -e "  ${PURPLE}1.${RESET} 前往 ${PURPLE}https://code.emoera.cn/settings${RESET} 创建 API Token"
  echo ""
  echo -e "  ${PURPLE}2.${RESET} 配置认证:"
  echo -e "     ${GREEN}yuncode login${RESET}"
  echo ""
  echo -e "  ${PURPLE}3.${RESET} 开始使用:"
  echo -e "     ${GREEN}yuncode push \"Hello World\"${RESET}    ${DIM}# 上传文本${RESET}"
  echo -e "     ${GREEN}yuncode push -f file.py${RESET}        ${DIM}# 上传文件${RESET}"
  echo -e "     ${GREEN}yuncode list${RESET}                   ${DIM}# 查看列表${RESET}"
  echo -e "     ${GREEN}yuncode pull <id>${RESET}              ${DIM}# 获取内容${RESET}"
  echo ""
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  echo -e "  ${DIM}文档: https://github.com/dijkstra402/emoera-code-cli${RESET}"
  echo -e "  ${DIM}反馈: https://github.com/dijkstra402/emoera-code-cli/issues${RESET}"
  echo ""
}

# ── 卸载功能 ──────────────────────────────────────────────
uninstall() {
  banner
  info "卸载 yuncode-cli..."

  # 移除 npm 全局包
  if npm list -g "$NPM_PACKAGE" &>/dev/null; then
    npm uninstall -g "$NPM_PACKAGE" 2>/dev/null || \
      sudo npm uninstall -g "$NPM_PACKAGE" 2>/dev/null || true
    success "已移除 npm 全局包"
  fi

  # 移除源码安装
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    success "已移除 $INSTALL_DIR"
  fi

  # 移除符号链接
  if [ -L "$HOME/.local/bin/yuncode" ]; then
    rm -f "$HOME/.local/bin/yuncode"
    success "已移除符号链接"
  fi

  echo ""
  info "配置文件保留在 ~/.yuncode/config.json"
  info "如需完全移除，请运行: rm -rf ~/.yuncode"
  echo ""

  success "卸载完成"
}

# ── 主流程 ────────────────────────────────────────────────
main() {
  # 支持 --uninstall 参数
  if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "uninstall" ]; then
    uninstall
    exit 0
  fi

  banner

  info "检测系统环境..."
  detect_os
  detect_distro
  detect_pkg_manager

  success "系统: $OS ($DISTRO) | 包管理器: $PKG_MANAGER"
  echo ""

  info "检查依赖..."
  check_nodejs
  check_npm

  install_cli
  verify_install
  show_next_steps
}

main "$@"
