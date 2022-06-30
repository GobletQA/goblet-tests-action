import { cloneAltRepo } from './cloneAltRepo'
import { repoLocation } from './repoLocation'
import { config } from '../../configs/action.config'

/**
 * Gets the path to the repo where the tests exist that should be run
 * Then saves it to a file
 */
export const getRepoDir = async () => {
  config.git.altRepo ? await cloneAltRepo() : await repoLocation(config.paths.workspace)
}

require.main === module && getRepoDir()
