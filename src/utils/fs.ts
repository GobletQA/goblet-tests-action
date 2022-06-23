import os from 'os'
import path from 'path'
import { ensureEnv } from './envs'
import { fileSys } from '@keg-hub/cli-utils'

export const ensureDirExists = (dirLoc: string) => {
  if (!fileSys.ensureDirSync(dirLoc))
    throw new Error(`Could not create directory: ${dirLoc}`)

  return dirLoc
}

export const resolveCacheLoc = () => {
  const cacheFile = ensureEnv(
    `GOBLET_CACHE_FILE`,
    path.join(os.tmpdir(), `goblet-cache/cache.json`)
  )
  ensureDirExists(path.dirname(cacheFile))

  return cacheFile
}
