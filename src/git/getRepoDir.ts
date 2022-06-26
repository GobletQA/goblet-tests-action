import { cloneAltRepo } from './cloneAltRepo'
import { repoLocation } from './repoLocation'
import { config } from '../../configs/action.config'

export const getRepoDir = async () => {
  config.git.altRepo ? await cloneAltRepo() : await repoLocation(config.paths.workspace)
}

require.main === module && getRepoDir()
