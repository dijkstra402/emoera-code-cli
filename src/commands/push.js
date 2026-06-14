import fs from 'fs'
import path from 'path'
import ora from 'ora'
import { apiRequest } from '../api.js'
import { brand, field, divider, success, error, formatSize } from '../ui.js'

// 过期时间预设
const EXPIRE_PRESETS = {
  '1h': 3600000, '6h': 21600000, '12h': 43200000,
  '1d': 86400000, '3d': 259200000, '7d': 604800000,
  '14d': 1209600000, '30d': 2592000000,
}

export async function pushCommand(content, options) {
  // 方式1: 上传文件
  if (options.file) {
    await pushFile(options)
    return
  }

  // 方式2: 从 stdin 读取
  if (content === '-' || (!content && !process.stdin.isTTY)) {
    content = await readStdin()
  }

  // 方式3: 直接传入文本参数
  if (!content) {
    console.log(error('请提供内容'))
    console.log(brand.muted('  用法:'))
    console.log(brand.primary('    yuncode push "文本"'))
    console.log(brand.primary('    echo "文本" | yuncode push -'))
    console.log(brand.primary('    yuncode push -f 文件路径'))
    process.exit(1)
  }

  const isCode = options.type === 'code' || !!options.language
  const language = options.language || ''
  const title = options.title || autoTitle(content)

  const spinner = ora({ text: '上传中...', color: 'magenta' }).start()

  try {
    const body = {
      content, title, language,
      password: options.password || '',
      isPublic: !options.private,
      requireLogin: !!options.requireLogin,
    }
    if (options.expire) body.expiresAt = calcExpireTime(options.expire)

    const res = await apiRequest('POST', '/v1/clips', { body })

    spinner.succeed(brand.success('上传成功'))
    console.log()
    console.log(field('标题', res.title || title))
    console.log(field('类型', isCode ? brand.secondary(`代码 (${language || 'auto'})`) : brand.accent('纯文本')))
    console.log(field('访问', accessLabel(options)))
    console.log(field('有效期', expireLabel(options.expire)))
    if (options.password) console.log(field('密码', brand.warning('已设置')))
    console.log(divider())
    console.log(field('Share ID', brand.primary(res.shareId)))
    console.log(field('链接', brand.primary(`https://code.emoera.cn/share/${res.shareId}`)))
    console.log()
  } catch (err) {
    spinner.fail(brand.error(`上传失败: ${err.message}`))
    process.exit(1)
  }
}

async function pushFile(options) {
  const filePath = path.resolve(options.file)

  if (!fs.existsSync(filePath)) {
    console.log(error(`文件不存在: ${filePath}`))
    process.exit(1)
  }

  const stat = fs.statSync(filePath)
  if (stat.size > 50 * 1024 * 1024) {
    console.log(error('文件大小超过 50MB 限制'))
    process.exit(1)
  }

  const fileName = path.basename(filePath)
  const title = options.title || fileName

  const spinner = ora({
    text: `上传 ${fileName} (${formatSize(stat.size)})...`,
    color: 'magenta'
  }).start()

  try {
    const fileBuffer = fs.readFileSync(filePath)
    const formData = new FormData()
    formData.append('file', new Blob([fileBuffer]), fileName)
    formData.append('title', title)
    formData.append('isPublic', options.private ? 'false' : 'true')
    if (options.password) formData.append('password', options.password)
    if (options.expire) formData.append('expiresAt', calcExpireTime(options.expire))

    const res = await apiRequest('POST', '/v1/clips/upload', {
      body: formData, headers: {}
    })

    spinner.succeed(brand.success('上传成功'))
    console.log()
    console.log(field('文件名', res.fileName || fileName))
    console.log(field('大小', formatSize(res.fileSize || stat.size)))
    console.log(field('标题', res.title || title))
    console.log(field('访问', accessLabel(options)))
    console.log(field('有效期', expireLabel(options.expire)))
    if (options.password) console.log(field('密码', brand.warning('已设置')))
    console.log(divider())
    console.log(field('Share ID', brand.primary(res.shareId)))
    console.log(field('链接', brand.primary(`https://code.emoera.cn/share/${res.shareId}`)))
    console.log()
  } catch (err) {
    spinner.fail(brand.error(`上传失败: ${err.message}`))
    process.exit(1)
  }
}

// ===== 工具函数 =====

function autoTitle(content) {
  const firstLine = content.split('\n').find(l => l.trim()) || ''
  const trimmed = firstLine.trim()
  return trimmed.length <= 60 ? trimmed : trimmed.substring(0, 57) + '...'
}

function accessLabel(opts) {
  if (opts.private) return brand.error('私有')
  if (opts.requireLogin) return brand.warning('需要登录')
  return brand.success('公开分享')
}

function expireLabel(expire) {
  if (!expire) return brand.success('永不过期')
  const labels = {
    '1h': '1 小时', '6h': '6 小时', '12h': '12 小时',
    '1d': '1 天', '3d': '3 天', '7d': '7 天',
    '14d': '14 天', '30d': '30 天',
  }
  return brand.warning(labels[expire] || expire)
}

function readStdin() {
  return new Promise((resolve) => {
    let data = ''
    process.stdin.setEncoding('utf-8')
    process.stdin.on('data', (chunk) => { data += chunk })
    process.stdin.on('end', () => resolve(data.trim()))
  })
}

function calcExpireTime(timeStr) {
  if (EXPIRE_PRESETS[timeStr]) {
    return new Date(Date.now() + EXPIRE_PRESETS[timeStr]).toISOString().slice(0, 19)
  }
  const match = timeStr.match(/^(\d+)(h|d)$/)
  if (!match) {
    console.log(error('无效的过期时间格式'))
    console.log(brand.muted('  支持: 1h, 6h, 12h, 1d, 3d, 7d, 14d, 30d'))
    process.exit(1)
  }
  const [, num, unit] = match
  const ms = unit === 'h' ? parseInt(num) * 3600000 : parseInt(num) * 86400000
  return new Date(Date.now() + ms).toISOString().slice(0, 19)
}
