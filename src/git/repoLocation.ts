import { fileSys } from '@keg-hub/cli-utils'
import { config } from '../../configs/action.config'

/**
 * Writes the location of the mounted git repo to a file
 */
export const repoLocation = async (repoLoc: string) => {
  await fileSys.writeFile(config.paths.actionRepoLoc, repoLoc)
  return true
}
