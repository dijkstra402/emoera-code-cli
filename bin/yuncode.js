#!/usr/bin/env node

import { Command } from 'commander'
import { loginCommand } from '../src/commands/login.js'
import { pushCommand } from '../src/commands/push.js'
import { pullCommand } from '../src/commands/pull.js'
import { listCommand } from '../src/commands/list.js'
import { configCommand } from '../src/commands/config.js'
import { BANNER, brand } from '../src/ui.js'

const program = new Command()

program
  .name('yuncode')
  .description('E时代云剪切板命令行工具')
  .version('1.0.0', '-v, --version')
  .addHelpText('before', BANNER)

program
  .command('login')
  .description('配置 API Token 进行认证')
  .action(loginCommand)

program
  .command('push [content]')
  .description('上传内容到云剪切板')
  .option('-f, --file <path>', '上传文件')
  .option('-t, --title <title>', '设置标题')
  .option('-T, --type <type>', '内容类型: text | code', 'text')
  .option('-l, --language <lang>', '代码语言（python, javascript, go ...）')
  .option('-e, --expire <time>', '过期时间: 1h, 6h, 1d, 7d, 30d')
  .option('-p, --password <pwd>', '设置访问密码')
  .option('--private', '设为私有（默认公开）')
  .option('--require-login', '需要登录才能查看')
  .action(pushCommand)

program
  .command('pull <shareId>')
  .description('获取剪切板内容')
  .option('-o, --output <path>', '保存到文件')
  .action(pullCommand)

program
  .command('list')
  .alias('ls')
  .description('列出最近的剪切板')
  .option('-n, --number <count>', '显示数量', '10')
  .action(listCommand)

program
  .command('config')
  .description('查看或修改配置')
  .argument('[action]', 'get / set')
  .argument('[key]', '配置项名称')
  .argument('[value]', '配置项值')
  .action(configCommand)

// 无参数时显示 Banner + 帮助
if (process.argv.length <= 2) {
  console.log(BANNER)
  console.log(brand.muted('  使用 yuncode --help 查看所有命令\n'))
  console.log(brand.muted('  快速开始:'))
  console.log(brand.primary('    yuncode login') + brand.muted('              配置 Token'))
  console.log(brand.primary('    yuncode push "内容"') + brand.muted('        上传文本'))
  console.log(brand.primary('    yuncode push -f file.py') + brand.muted('   上传文件'))
  console.log(brand.primary('    yuncode list') + brand.muted('              查看列表'))
  console.log(brand.primary('    yuncode pull <id>') + brand.muted('         获取内容'))
  console.log()
} else {
  program.parse()
}
