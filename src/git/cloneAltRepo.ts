import { git } from './git'
import { setGitUser } from './setGitUser'
import { config } from '@configs/action.config'
import { linkToMountRoot } from './linkToMountRoot'

/**
 * Uses git to clone the alt repo then switches to the
 */
export const cloneAltRepo = async () => {
  const { repo } = config.git
  await setGitUser()

  await git([`clone`, `--recurse-submodules`, repo.url, config.paths.altCloneLoc], {
    cwd: config.paths.altCloneParentDir,
  })
  await git([`fetch`], { cwd: config.paths.altCloneLoc })

  repo.branch && (await git([`checkout`, repo.branch], { cwd: config.paths.altCloneLoc }))

  return await linkToMountRoot(config.paths.altCloneLoc)
}
