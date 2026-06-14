<p align="center">
  <pre>
  ███████╗  时代云剪切板 CLI
  ██╔════╝  ─────────────
  █████╗    Terminal → Cloud
  ██╔══╝    随时存取，一键分享
  ███████╗  code.emoera.cn
  ╚══════╝
  </pre>
</p>

<p align="center">
  <strong>在终端中快速存取云剪切板内容</strong>
</p>

<p align="center">
  <a href="https://code.emoera.cn">官网</a> ·
  <a href="https://github.com/dijkstra402/emoera-code-cli">GitHub</a> ·
  <a href="#安装">安装</a> ·
  <a href="#使用">使用</a> ·
  <a href="#命令参考">命令参考</a>
</p>

---

## 特性

- 🚀 **一键上传** — 文本、代码、文件一条命令搞定
- 📥 **快速获取** — 通过 Share ID 获取任意剪切板内容
- 🔗 **管道支持** — 无缝集成 Unix 管道，`echo "data" | yuncode push -`
- 🎨 **美观输出** — E时代品牌配色，舒适的终端体验
- 🔐 **Token 认证** — 基于 PAT 的安全认证机制
- ⚡ **零依赖运行时** — 仅需 Node.js 18+，无原生模块

## 安装

### 一键安装（推荐）

**macOS / Linux:**

```bash
curl -fsSL https://code.emoera.cn/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://code.emoera.cn/install.ps1 | iex
```

### npm 安装

```bash
npm install -g @eera/yuncode-cli
```

### 从源码安装

```bash
git clone https://github.com/dijkstra402/emoera-code-cli.git
cd emoera-code-cli
npm install
npm link
```

### 卸载

```bash
# macOS / Linux
curl -fsSL https://code.emoera.cn/install.sh | bash -s -- --uninstall

# Windows
irm https://code.emoera.cn/install.ps1 | iex -- --uninstall

# 或通过 npm
npm uninstall -g @eera/yuncode-cli
```

## 使用

### 1. 获取 Token

前往 [code.emoera.cn/settings](https://code.emoera.cn/settings) 创建一个 API Token。

### 2. 配置认证

```bash
yuncode login
# 按照提示输入 Token（以 yc_ 开头）
```

### 3. 开始使用

```bash
# 上传文本
yuncode push "Hello World"

# 上传文件
yuncode push -f ./code.py

# 从 stdin 上传
echo "pipeline data" | yuncode push -
cat script.sh | yuncode push - -t "部署脚本" -l bash

# 查看列表
yuncode list

# 获取内容
yuncode pull abc123

# 保存到文件
yuncode pull abc123 -o output.txt
```

## 命令参考

### `yuncode login`

交互式输入 API Token 并保存到本地配置。

```bash
yuncode login
```

### `yuncode push [content]`

上传内容到云剪切板。

```bash
yuncode push "要上传的文本"
```

| 参数 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--file <path>` | `-f` | 上传文件 | - |
| `--title <title>` | `-t` | 设置标题 | 自动截取首行 |
| `--type <type>` | `-T` | 内容类型: `text` \| `code` | `text` |
| `--language <lang>` | `-l` | 代码语言 | 自动检测 |
| `--expire <time>` | `-e` | 过期时间 | 永不过期 |
| `--password <pwd>` | `-p` | 访问密码 | - |
| `--private` | - | 设为私有 | 公开 |
| `--require-login` | - | 需登录查看 | 不需要 |

**过期时间格式:** `1h` `6h` `12h` `1d` `3d` `7d` `14d` `30d`

**示例:**

```bash
# 上传代码，设置语言和标题
yuncode push -f main.py -t "入口文件" -l python

# 带密码和过期时间
yuncode push "秘密信息" -p mypassword -e 1d

# 私有 + 需登录
yuncode push -f config.json --private --require-login

# 管道 + 代码类型
cat app.js | yuncode push - -T code -l javascript
```

### `yuncode pull <shareId>`

获取剪切板内容。

```bash
yuncode pull abc123
yuncode pull abc123 -o output.txt   # 保存到文件
```

| 参数 | 简写 | 说明 |
|------|------|------|
| `--output <path>` | `-o` | 保存到文件 |

### `yuncode list`

列出最近的剪切板。

```bash
yuncode list        # 最近 10 条
yuncode list -n 20  # 最近 20 条
yuncode ls          # 别名
```

| 参数 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--number <count>` | `-n` | 显示数量 | 10 |

### `yuncode config`

查看或修改配置。

```bash
yuncode config                          # 查看当前配置
yuncode config get api_url              # 查看单个配置项
yuncode config set api_url <url>        # 设置 API 地址
yuncode config set token <token>        # 设置 Token
```

**可用配置项:**

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `api_url` | API 服务器地址 | `https://codebackend.emoera.cn/api` |
| `token` | 个人访问令牌 | - |

配置文件位于 `~/.yuncode/config.json`。

## 管道与脚本集成

yuncode-cli 完整支持 Unix 管道和脚本集成：

```bash
# 将命令输出上传到云剪切板
ls -la | yuncode push - -t "文件列表"

# 上传日志文件
tail -100 /var/log/app.log | yuncode push - -t "最近100行日志"

# 在 CI/CD 中使用
yuncode push -f ./build/report.html -t "构建报告 #${BUILD_NUMBER}" -e 7d

# 将剪切板内容传递给其他命令
yuncode pull abc123 -o - | grep "ERROR"
```

## 环境要求

- **Node.js** ≥ 18.0.0
- **操作系统:** macOS / Linux / Windows
- **网络:** 需要访问 `codebackend.emoera.cn`

## 开发

```bash
# 克隆仓库
git clone https://github.com/emoera/yuncode-cli.git
cd yuncode-cli

# 安装依赖
npm install

# 本地链接
npm link

# 运行
yuncode --help
```

## 许可证

[MIT](LICENSE)

## 相关项目

- [E时代云剪切板](https://code.emoera.cn) — Web 应用
- [Chrome 扩展](https://github.com/dijkstra402/emoera-code-cli/tree/main/chrome-extension) — 浏览器扩展

---

<p align="center">
  <sub>Made with 💜 by E时代</sub>
</p>
