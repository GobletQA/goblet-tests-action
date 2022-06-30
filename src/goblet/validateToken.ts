// import { writeCache } from './cache'
// import { exitError } from '../utils/exitError'
import { config } from '../../configs/action.config'

/**
 * Calls the goblet API to validate the passed in token is valid
 */
const callGobletApi = async () => {
  const { token } = config.goblet
  if (!token) throw new Error(`Goblet Auth Token is invalid.`)

  // TODO: Add api call to validate the token
  return { valid: true, message: ``, data: {} }
}

/**
 * Call the goblet backend API to validate the passed in token
 * If valid save the response to a file so it can be accessed later
 * @throws
 */
export const validateToken = async () => {
  const { valid } = await callGobletApi()
  return valid
  // valid ? await writeCache(data) : exitError(message)
}

require.main === module && validateToken()
