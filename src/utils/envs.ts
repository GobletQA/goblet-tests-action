/**
 * Returns true if an ENV value exists otherwise false
 * @param {String} name - Name of the ENV to check if its value exists
 *
 * @returns {Boolean} - State of the ENV value existence
 */
export const envExists = (name: string) => {
  return Boolean((process.env[name] || ``).trim().length)
}

/**
 * Checks if an ENV value exists and returns it, or uses the passed alt
 * If neither exists, it throws an error
 * @throws
 * @param {String} name - Name of the ENV to check if its value exists
 * @param {String} alt - Alt ENV or value to use if name ENV does not exist
 *
 * @returns {String} - Value of the ENV from name or the alt
 */
export const ensureEnv = (name: string, alt?: string) => {
  if (process.env[name]) return process.env[name]
  if (alt) return process.env[alt] || alt

  throw new Error(`Missing value for env variable ${name}`)
}
