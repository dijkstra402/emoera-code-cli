import chalk from 'chalk'

// E时代品牌色
export const brand = {
  primary: chalk.hex('#6366f1'),
  secondary: chalk.hex('#8b5cf6'),
  accent: chalk.hex('#a78bfa'),
  success: chalk.hex('#34d399'),
  error: chalk.hex('#f87171'),
  warning: chalk.hex('#fbbf24'),
  dim: chalk.dim,
  muted: chalk.gray,
}

// 品牌 ASCII Art Banner
export const BANNER = `
${brand.primary('  ███████╗')}${brand.secondary('  时代云剪切板')}
${brand.primary('  ██╔════╝')}${brand.muted('  ─────────────')}
${brand.primary('  █████╗  ')}${brand.muted('  Terminal → Cloud')}
${brand.primary('  ██╔══╝  ')}${brand.muted('  随时存取，一键分享')}
${brand.primary('  ███████╗')}${brand.muted('  code.emoera.cn')}
${brand.primary('  ╚══════╝')}
`

// 紧凑版 Banner（用于命令输出）
export const BANNER_COMPACT = brand.primary('  ◆ ') + chalk.bold('E时代云剪切板') + brand.muted(' · yuncode-cli')

// 分隔线
export function divider(char = '─', len = 45) {
  return brand.muted('  ' + char.repeat(len))
}

// 格式化字段输出
export function field(label, value, labelWidth = 8) {
  const pad = ' '.repeat(Math.max(0, labelWidth - displayWidth(label)))
  return brand.muted(`  ${label}${pad}  `) + value
}

// 成功消息
export function success(msg) {
  return brand.success('  ✓ ') + msg
}

// 错误消息
export function error(msg) {
  return brand.error('  ✗ ') + msg
}

// 提示信息
export function hint(msg) {
  return brand.muted('  → ') + brand.muted(msg)
}

// 计算显示宽度（考虑中文字符）
export function displayWidth(str) {
  let w = 0
  for (const ch of String(str)) {
    w += ch.codePointAt(0) > 0x7f ? 2 : 1
  }
  return w
}

// 截断字符串
export function truncate(str, maxLen) {
  let width = 0
  let result = ''
  for (const char of str) {
    const w = char.codePointAt(0) > 0x7f ? 2 : 1
    if (width + w > maxLen - 2) {
      return result + '..'
    }
    width += w
    result += char
  }
  return result
}

// 右填充（中文感知）
export function padRight(str, len) {
  const padding = Math.max(0, len - displayWidth(str))
  return str + ' '.repeat(padding)
}

// 格式化文件大小
export function formatSize(bytes) {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / 1048576).toFixed(1) + ' MB'
}

// 格式化时间
export function formatTime(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now - date
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)} 分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)} 小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)} 天前`
  return date.toLocaleDateString('zh-CN')
}
