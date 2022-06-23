import { set } from '@keg-hub/jsutils'
import { fileSys } from '@keg-hub/cli-utils'
import { config } from '@configs/action.config'

/**
 * Gets the saved cache data from the cache file
 *
 * @returns {Object} - The previously saved cache object
 */
export const getCache = async () => {
  try {
    const cacheBuffer: Buffer = await fileSys.readFile(config.paths.cache)
    return JSON.parse(cacheBuffer.toString())
  }
  catch (err) {
    return {}
  }
}

/**
 * Writes passed in data to the cache file
 * @param {Object|String} data - Cache object to be saved
 *
 * @returns {Boolean} - True if the data object was saved to cache
 */
export const writeCache = async (data: string | Record<any, any>) => {
  if (typeof data !== 'string') data = JSON.stringify(data)

  await fileSys.writeFile(data, config.paths.cache)

  return true
}

/**
 * Writes the passed in key / value pair to the cache object
 * @param {String} key - Path on the cache object where the value should be saved
 * @param {*} value - Data that should be saved to the cache object
 *
 * @returns {Boolean} - True if the key / value were saved to cache
 */
export const upsertCache = async (key: string, value: any) => {
  const cache = await getCache()
  set(cache, key, value)
  return await writeCache(cache)
}
