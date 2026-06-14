import inquirer from 'inquirer'
import ora from 'ora'
import { loadConfig, saveConfig } from '../config.js'
import { BANNER_COMPACT, brand, success, error, hint, divider } from '../ui.js'

export async function loginCommand() {
  console.log()
  console.log(BANNER_COMPACT)
  console.log(divider())
  console.log(hint('前往 https://code.emoera.cn/settings 创建 API Token'))
  console.log(hint('Token 格式: yc_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'))
  console.log()

  const { token } = await inquirer.prompt([
    {
      type: 'password',
      name: 'token',
      message: brand.accent('API Token:'),
      mask: '•',
      validate: (input) => {
        if (!input.trim()) return '请输入 Token'
        if (!input.startsWith('yc_')) return 'Token 应以 yc_ 开头'
        if (input.length < 10) return 'Token 长度不正确'
        return true
      }
    }
  ])

  const spinner = ora({ text: '验证 Token...', color: 'magenta' }).start()

  try {
    const config = loadConfig()
    config.token = token.trim()

    const url = `${config.api_url}/v1/clips?page=0&size=1`
    const response = await fetch(url, {
      headers: { 'Authorization': `Bearer ${config.token}` }
    })

    if (response.ok) {
      saveConfig(config)
      spinner.succeed(brand.success('Token 验证通过，已保存'))
      console.log()
      console.log(hint('配置文件: ~/.yuncode/config.json'))
      console.log()
      console.log(brand.muted('  现在可以使用:'))
      console.log(brand.primary('    yuncode push "内容"') + brand.muted('    上传文本'))
      console.log(brand.primary('    yuncode list') + brand.muted('              查看列表'))
      console.log(brand.primary('    yuncode pull <id>') + brand.muted('         获取内容'))
      console.log()
    } else {
      spinner.fail(brand.error('Token 无效或已过期'))
    }
  } catch (err) {
    spinner.fail(brand.error(`验证失败: ${err.message}`))
  }
}
