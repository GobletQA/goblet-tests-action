import { promises } from 'fs'
import { config } from '@configs/action.config'

/**
 * Gets the saved cache data from the cache file
 */
export const getCache = async () => {
  try {
    const cacheBuffer: Buffer = await promises.readFile(config.goblet.cache)
    return JSON.parse(cacheBuffer.toString())
  }
  catch (err) {
    return {}
  }
}

/**
 * Writes passed in data to the cache file
 */
export const writeCache = async (data: string | Record<any, any>) => {
  if (typeof data !== 'string') data = JSON.stringify(data)

  await promises.writeFile(data, config.goblet.cache)

  return true
}
