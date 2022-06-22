import os from 'os'
import path from 'path'

const envExists = (name: string) => {
  return Boolean((process.env[name] || ``).trim().length)
}

const ensureEnv = (name: string, alt?: string) => {
  if (process.env[name]) return process.env[name]
  if (alt) return process.env[alt] || alt

  throw new Error(`Missing value for env variable ${name}`)
}

const altRepo = envExists(`GIT_ALT_REPO`)
const resolveGitRepo = () => {
  const { GIT_ALT_REPO, GIT_ALT_USER, GITHUB_REPOSITORY, GITHUB_REPOSITORY_OWNER } =
    process.env

  const repoName = altRepo
    ? GIT_ALT_REPO.includes('/')
      ? GIT_ALT_REPO
      : envExists(`GIT_ALT_USER`)
        ? `${GIT_ALT_USER}/${GIT_ALT_REPO}`
        : `${GITHUB_REPOSITORY_OWNER}/${GIT_ALT_REPO}`
    : GITHUB_REPOSITORY

  const [user, name] = repoName.includes('/')
    ? repoName.split('/')
    : [process.env.GITHUB_REPOSITORY_OWNER, repoName]

  return {
    name,
    user,
    active: true,
    collection: `repos`,
    provider: `github.com`,
    branch: process.env.GITHUB_REF_NAME,
    url: `https://github.com/${repoName}`,
  }
}

const resolveGitUser = () => {
  const {
    GIT_ALT_REPO,
    GIT_ALT_USER,
    GITHUB_REPOSITORY_OWNER,
    GIT_ALT_EMAIL = `goblet-action@users.noreply.github.com`,
  } = process.env

  const user = envExists(`GIT_ALT_USER`)
    ? GIT_ALT_USER
    : envExists(`GIT_ALT_REPO`) && GIT_ALT_REPO.includes('/')
      ? GIT_ALT_REPO.split('/').shift()
      : GITHUB_REPOSITORY_OWNER

  return {
    gitUser: user,
    lastName: `action`,
    firstName: `goblet`,
    email: GIT_ALT_EMAIL,
  }
}

export const config = {
  goblet: {
    token: ensureEnv(`GOBLET_TOKEN`),
    cache: ensureEnv(`GOBLET_CACHE_FILE`, path.join(os.tmpdir(), `goblet-cache`)),
    api: ensureEnv(`GOBLET_API`, `https://herkin.backend.herkin.app/auth/token`),
  },
  git: {
    altRepo,
    user: resolveGitUser(),
    repo: resolveGitRepo(),
    token: ensureEnv(`GOBLET_GIT_TOKEN`),
  },
}
