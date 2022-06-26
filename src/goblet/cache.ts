import { config } from '../../configs/action.config'
import { fileSys, error } from '@keg-hub/cli-utils'
import { set, get, deepMerge } from '@keg-hub/jsutils'

/**
 * Gets the saved cache data from the cache file
 *
 * @returns {Object} - The previously saved cache object
 */
export const getCache = async () => {
  try {
    delete require.cache[config.paths.cache]
    return require(config.paths.cache)
  }
  catch (err) {
    console.error(`[Goblet Error] Error reading cache file.\n${err.message}`)
    return {}
  }
}

/**
 * Writes passed in data to the cache file
 * @param {Object|String} data - Cache object to be saved
 *
 * @returns {Boolean} - True if the data object was saved to cache
 */
export const writeCache = async (data: Record<any, any>) => {
  const cache = await getCache()

  await fileSys.writeFile(
    config.paths.cache,
    JSON.stringify(deepMerge(cache, data), null, 2)
  )

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

  const [err] = await fileSys.writeFile(
    config.paths.cache,
    JSON.stringify(deepMerge(cache), null, 2)
  )

  return err ? error.throwError(err) : true
}

/**
 * Prints a cache key value to stdout
 * @param {String} key - Path on the cache object that should be printed
 *
 * @returns {void}
 */
export const printCache = async (key?: string) => {
  key = key || process.argv.slice(2).shift()
  const cache = await getCache()
  const toPrint = key ? get(cache, key) : cache

  toPrint
    ? console.log(toPrint)
    : error.throwError(`Cache${key ? ' key ' + key : ''} not found.`)
}

require.main === module && printCache()
