import ora from 'ora'
import { apiRequest } from '../api.js'
import { BANNER_COMPACT, brand, divider, field, padRight, truncate, formatTime } from '../ui.js'

export async function listCommand(options) {
  const spinner = ora({ text: '加载中...', color: 'magenta' }).start()

  try {
    const size = Math.min(parseInt(options.number) || 10, 50)
    const res = await apiRequest('GET', `/v1/clips?page=0&size=${size}`)

    spinner.stop()

    const items = res.items || []
    if (items.length === 0) {
      console.log()
      console.log(BANNER_COMPACT)
      console.log(brand.muted('\n  暂无剪切板内容\n'))
      return
    }

    console.log()
    console.log(BANNER_COMPACT + brand.muted(`  共 ${res.totalElements} 条`))
    console.log(divider())

    // 表头
    console.log(
      brand.muted('  ') +
      brand.dim(padRight('ID', 40)) +
      brand.dim(padRight('类型', 8)) +
      brand.dim(padRight('标题', 28)) +
      brand.dim('时间')
    )
    console.log(divider('─', 88))

    for (const item of items) {
      const icon = item.contentType === 'FILE' ? '📁' :
                   item.contentType === 'CODE' ? '💻' : '📝'
      const typeText = item.contentType === 'FILE' ? '文件' :
                       item.contentType === 'CODE' ? '代码' : '文本'
      const title = truncate(item.title || '(无标题)', 26)
      const time = formatTime(item.createdAt)

      console.log(
        '  ' +
        brand.primary(padRight(item.shareId, 40)) +
        padRight(`${icon} ${typeText}`, 8) +
        padRight(title, 28) +
        brand.muted(time)
      )
    }

    console.log(divider())
    console.log(brand.muted('  yuncode pull <ID> 获取内容'))
    console.log()

  } catch (err) {
    spinner.fail(brand.error(`加载失败: ${err.message}`))
    process.exit(1)
  }
}
