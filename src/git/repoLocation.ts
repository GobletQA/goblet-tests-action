import { fileSys } from '@keg-hub/cli-utils'
import { config } from '../../configs/action.config'
// import { upsertCache } from '../goblet/cache'

export const repoLocation = async (repoLoc: string) => {
  await fileSys.writeFile(config.paths.actionRepoLoc, repoLoc)
  // await upsertCache(`paths`, { repoLoc })

  return true
}
