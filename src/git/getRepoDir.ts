import { cloneAltRepo } from './cloneAltRepo'
import { config } from '@configs/action.config'
import { linkToMountRoot } from './linkToMountRoot'

export const getRepoDir = async () => {
  config.git.altRepo
    ? await cloneAltRepo()
    : await linkToMountRoot(config.paths.workspace)
}

require.main === module && getRepoDir()
