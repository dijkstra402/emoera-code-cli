import fs from 'fs'
import path from 'path'
import os from 'os'

const CONFIG_DIR = path.join(os.homedir(), '.yuncode')
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.json')

const DEFAULT_CONFIG = {
  api_url: 'https://codebackend.emoera.cn/api',
  token: ''
}

/**
 * 读取配置文件
 */
export function loadConfig() {
  try {
    if (fs.existsSync(CONFIG_FILE)) {
      const raw = fs.readFileSync(CONFIG_FILE, 'utf-8')
      return { ...DEFAULT_CONFIG, ...JSON.parse(raw) }
    }
  } catch {
    // 配置损坏时用默认值
  }
  return { ...DEFAULT_CONFIG }
}

/**
 * 保存配置文件
 */
export function saveConfig(config) {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 })
  }
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2), { mode: 0o600 })
}

/**
 * 获取 API 基础 URL
 */
export function getApiUrl() {
  return loadConfig().api_url
}

/**
 * 获取 Token
 */
export function getToken() {
  return loadConfig().token
}
