import path from 'path'
import homeDir from 'os'
import { AppRoot } from '../constants'
import { exists } from '@keg-hub/jsutils'
import { fileSys } from '@keg-hub/cli-utils'
import { getConfigToken } from './configToken'

const { readFileSync } = fileSys
const NPM_RC_FILE = `.npmrc`
const AUTH_TOKEN_REF = `_authToken=`
const NPM_TOKEN_STRS = [`NPM_TOKEN`, `NPM_AUTH_TOKEN`]


/**
 * Loads the content of the passed on location
 * Then tries to parse the npm token form the content
 * @param {string} location - Path to an .npmrc file
 *
 * @returns {string|boolean} - Found NPM Token or false
 */
const loadNpmRC = (location) => {
  try {
    const content = readFileSync(location).toString()
    return (
      content &&
      content.split('\n').reduce((found, line) => {
        // If already found, or not the correct line, just return
        if (found || !line.includes(AUTH_TOKEN_REF)) return found

        // Parse the token from the line
        const token = line.split(AUTH_TOKEN_REF).pop().trim()

        const filtered = Boolean(
          NPM_TOKEN_STRS.filter((ENV_TOKEN_NAME) => {
            return (
              ENV_TOKEN_NAME.includes(token) || token.includes(ENV_TOKEN_NAME)
            )
          }).length,
        )

        return filtered ? found : token
      }, false)
    )
  } catch (err) {
    return false
  }
}

/**
 * Loops over the passed in locations build a path to the locations .npmrc file
 * It then tries to load and parse the NPM_TOKEN from the file by calling loadNpmRC
 *
 * @returns {string|boolean} - Found NPM Token or false
 */
const loopFindNpmRcFile = (locations) => {
  return locations.reduce((found, location) => {
    return found || loadNpmRC(path.join(location, NPM_RC_FILE))
  }, false)
}

/**
 * Checks the canvas-app and the home directory for the .npmrc file
 * Parses the the token from the .npmrc file if it's a real token
 *
 * @returns {string|boolean} - Found NPM Token or false
 */
export const getNpmToken = (password?:string|Boolean) => {
  const { NPM_TOKEN, NPM_AUTH_TOKEN, GIT_TOKEN } = process.env
  
  const npmToken = NPM_TOKEN || NPM_AUTH_TOKEN

  if (exists(npmToken)){
    if(!NPM_TOKEN) process.env.NPM_TOKEN = npmToken
    if(!NPM_AUTH_TOKEN) process.env.NPM_AUTH_TOKEN = npmToken

    return npmToken
  }

  let foundToken
  exists(GIT_TOKEN) && (foundToken = GIT_TOKEN)

  // Try to load the token from the global config
  const kegToken = getConfigToken(password)
  if(kegToken){
    if(!GIT_TOKEN) process.env.GIT_TOKEN = kegToken
    foundToken = kegToken
  }

  // Try to load the token from any repo in the mono-repo or home directory
  foundToken = foundToken
    || loopFindNpmRcFile([homeDir, AppRoot])

  if (!foundToken) return ``

  // If the token is found, then add it to the current process
  process.env.NPM_TOKEN = foundToken
  process.env.NPM_AUTH_TOKEN = foundToken

  return foundToken
}
