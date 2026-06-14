import { getApiUrl, getToken } from './config.js'
import chalk from 'chalk'

/**
 * 封装 API 请求
 */
export async function apiRequest(method, path, options = {}) {
  const token = getToken()
  if (!token) {
    console.error(chalk.red('✗ 未配置 Token，请先运行: yuncode login'))
    process.exit(1)
  }

  const url = `${getApiUrl()}${path}`
  const headers = {
    'Authorization': `Bearer ${token}`,
    ...options.headers
  }

  if (!(options.body instanceof FormData)) {
    headers['Content-Type'] = 'application/json'
  }

  try {
    const response = await fetch(url, {
      method,
      headers,
      body: options.body ? (options.body instanceof FormData ? options.body : JSON.stringify(options.body)) : undefined
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.error || data.message || `HTTP ${response.status}`)
    }

    return data
  } catch (error) {
    if (error.cause?.code === 'ECONNREFUSED') {
      console.error(chalk.red('✗ 无法连接到服务器，请检查网络或 API 地址'))
      process.exit(1)
    }
    throw error
  }
}
