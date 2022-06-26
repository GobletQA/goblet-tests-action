import { Logger } from '@keg-hub/cli-utils'
import { cloneAltRepo } from './cloneAltRepo'
import { repoLocation } from './repoLocation'
import { config } from '../../configs/action.config'

export const getRepoDir = async () => {
  config.git.altRepo ? await cloneAltRepo() : await repoLocation(config.paths.workspace)

  Logger.log(`[Goblet] Updated cache location ${config.paths.cache}`)
}

require.main === module && getRepoDir()
