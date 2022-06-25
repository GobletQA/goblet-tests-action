import { Logger } from '@keg-hub/cli-utils'
import { cloneAltRepo } from './cloneAltRepo'
import { upsertCache } from '../goblet/cache'
import { config } from '@configs/action.config'

export const getRepoDir = async () => {
  config.git.altRepo
    ? await cloneAltRepo()
    : await upsertCache(`paths`, { repoLoc: config.paths.workspace })

  Logger.log(`[Logger - Goblet] Updated cache location ${config.paths.cache}`)
}

require.main === module && getRepoDir()
