import crypto from 'node:crypto'
import { get } from '@keg-hub/jsutils'
import { constants, error, getKegGlobalConfig } from '@keg-hub/cli-utils'
const { GLOBAL_CONFIG_PATHS } = constants

const salt = 'a4E36cDq'
const secretFormat = 'hex'
const algorithm = 'aes-128-cbc'

const getKey = (password) => {
  const hash = crypto.createHash("sha1")
  hash.update(password)
  return hash.digest().slice(0, 16)
}

/**
 * Decrypts the passed in string
 * @param {string} str - String to be decrypted
 *
 * @returns {string} - Decrypted string
 */
const decrypt = (str:string, password:string|Boolean) => {
  const strSplit = str.split(':')
  const ivFromKey = Buffer.from(strSplit.shift(), secretFormat);
  const encryptedText = Buffer.from(strSplit.join(':'), secretFormat)

  const key = getKey(password || salt)
  const decipher = crypto.createDecipheriv(algorithm, key, ivFromKey)
  const decrypted = decipher.update(encryptedText)

  return Buffer.concat([decrypted, decipher.final()]).toString()
}

/**
 * Decrypts the token saved in the global config and returns it
 * @param {string|Boolean} password - Password to access the token
 * @param {string|Boolean} token - Value of the token
 *
 * @returns {void}
 */
export const getConfigToken = (password:string|Boolean=false, throwError:Boolean=false) => {
  try {
    const globalConfig = getKegGlobalConfig()
    return decrypt(get(globalConfig, `${GLOBAL_CONFIG_PATHS.GIT}.key`), password)
  }
  catch(e){
    throwError && error.throwError(`\n You entered an invalid password!`)
  }
}
