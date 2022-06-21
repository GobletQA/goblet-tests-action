import os from 'os'
import path from 'path'

const ensureEnv = (name: string, alt?: string) => {
  if (process.env[name]) return process.env[name]
  if (alt) return alt

  throw new Error(`Missing value for env variable ${name}`)
}

export const config = {
  goblet: {
    token: ensureEnv(`GOBLET_TOKEN`),
    cache: ensureEnv(`GOBLET_CACHE_FILE`, path.join(os.tmpdir(), `goblet-cache`)),
    api: ensureEnv(`GOBLET_API`, `https://herkin.backend.herkin.app/auth/token`),
  },
}
