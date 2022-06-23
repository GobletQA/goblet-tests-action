import path from 'path'
import { ensureDirExists } from '@utils/fs'
import { upsertCache } from '../goblet/cache'
import { config } from '@configs/action.config'
import { Logger, error, runCmd, fileSys } from '@keg-hub/cli-utils'

const buildMountPath = (repoLoc: string) => {
  return path.join(
    config.paths.mountRoot,
    config.git.user.gitUser,
    repoLoc.split(`/`).pop()
  )
}

export const linkToMountRoot = async (repoLoc: string) => {
  const mountTo = buildMountPath(repoLoc)

  Logger.log(`[Goblet] Mounting repo`)
  Logger.log(`  From: ${repoLoc}`)
  Logger.log(`  TO: ${mountTo}`)

  ensureDirExists(path.dirname(mountTo))

  const { error: lnErr, exitCode } = await runCmd(`ln`, [`-s`, repoLoc, mountTo], {
    exec: true,
  })
  exitCode && error.throwError(`[Goblet Error] Could not mount repo.\n${lnErr}`)

  ;(await fileSys.pathExists(mountTo))
    ? Logger.success(`[Goblet] Successfully mounted repo`)
    : error.throwError(`[Goblet Error] Could not mount repo: ${mountTo}`)

  Logger.log(`[Goblet] Saving mount location...`)

  await upsertCache(`paths`, mountTo)
  Logger.success(`[Goblet] Successfully saved repo mount location`)
}
