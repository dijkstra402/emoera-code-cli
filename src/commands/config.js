import { loadConfig, saveConfig } from '../config.js'
import { BANNER_COMPACT, brand, divider, field, success, error } from '../ui.js'

export function configCommand(action, key, value) {
  const config = loadConfig()

  // 无参数：显示当前配置
  if (!action || action === 'get') {
    if (key) {
      if (config[key] !== undefined) {
        const display = key === 'token' ? maskToken(config[key]) : config[key]
        console.log(`${key} = ${display}`)
      } else {
        console.log(error(`未知配置项: ${key}`))
        showAvailableKeys()
      }
    } else {
      console.log()
      console.log(BANNER_COMPACT)
      console.log(divider())
      console.log(field('API 地址', brand.primary(config.api_url)))
      console.log(field('Token', maskToken(config.token)))
      console.log(field('配置文件', brand.muted('~/.yuncode/config.json')))
      console.log()
    }
    return
  }

  if (action === 'set') {
    if (!key || value === undefined) {
      console.log(error('用法: yuncode config set <key> <value>'))
      showAvailableKeys()
      return
    }

    if (!['api_url', 'token'].includes(key)) {
      console.log(error(`未知配置项: ${key}`))
      showAvailableKeys()
      return
    }

    config[key] = value
    saveConfig(config)
    const display = key === 'token' ? maskToken(value) : value
    console.log(success(`${key} = ${display}`))
    return
  }

  console.log(error(`未知操作: ${action}，可用: get, set`))
}

function maskToken(token) {
  if (!token) return brand.muted('(未设置)')
  if (token.length <= 10) return '••••••••'
  return brand.accent(token.substring(0, 6)) + brand.muted('••••••••')
}

function showAvailableKeys() {
  console.log(brand.muted('\n  可用配置项:'))
  console.log(brand.muted('    api_url  ') + '— API 服务器地址')
  console.log(brand.muted('    token    ') + '— 个人访问令牌')
}
