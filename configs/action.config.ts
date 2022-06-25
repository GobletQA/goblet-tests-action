import path from 'path'
import { ensureEnv } from '@utils/envs'
import { ensureDirExists, resolveCacheLoc } from '@utils/fs'
import { altRepo, altCloneLoc, resolveGitRepo, resolveGitUser } from '@utils/git'

export const config = {
  goblet: {
    token: ensureEnv(`GOBLET_TOKEN`),
    api: ensureEnv(`GOBLET_API`, `https://herkin.backend.herkin.app/auth/token`),
  },
  git: {
    altRepo,
    user: resolveGitUser(),
    repo: resolveGitRepo(),
    token: ensureEnv(`GOBLET_GIT_TOKEN`),
  },
  paths: {
    altCloneLoc,
    altCloneParentDir: ensureDirExists(path.dirname(altCloneLoc)),
    cache: resolveCacheLoc(),
    workspace: ensureEnv(`GITHUB_WORKSPACE`),
    mountRoot: ensureDirExists(ensureEnv(`GOBLET_MOUNT_ROOT`)),
  },
}
