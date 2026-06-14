import fs from 'fs'
import path from 'path'
import ora from 'ora'
import { apiRequest } from '../api.js'
import { brand, field, divider, success } from '../ui.js'

export async function pullCommand(shareId, options) {
  const spinner = ora({ text: '获取中...', color: 'magenta' }).start()

  try {
    const res = await apiRequest('GET', `/v1/clips/${shareId}`)

    spinner.stop()

    // 文件类型
    if (res.contentType === 'FILE') {
      console.log()
      console.log(field('文件', res.fileName))
      console.log(field('下载', brand.primary(`https://code.emoera.cn/share/${shareId}`)))
      console.log()
      return
    }

    const content = res.content || ''

    // 保存到文件
    if (options.output) {
      const outputPath = path.resolve(options.output)
      fs.writeFileSync(outputPath, content, 'utf-8')
      console.log()
      console.log(success(`已保存到 ${outputPath}`))
      console.log()
      return
    }

    // 输出到终端
    console.log()
    if (res.title) {
      console.log(brand.primary('  ' + res.title))
      console.log(divider())
    }
    // 内容左侧带竖线装饰
    const lines = content.split('\n')
    for (const line of lines) {
      console.log(brand.muted('  │ ') + line)
    }
    console.log()

  } catch (err) {
    spinner.fail(brand.error(`获取失败: ${err.message}`))
    process.exit(1)
  }
}
