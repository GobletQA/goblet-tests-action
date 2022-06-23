import { envExists } from './envs'

export const altRepo = envExists(`GIT_ALT_REPO`)
export const altCloneLoc = `/goblet-action/alt-clone/repo`

export const resolveGitRepo = () => {
  const {
    GIT_ALT_REPO,
    GIT_ALT_USER,
    GIT_ALT_BRANCH,
    GITHUB_REF_NAME,
    GITHUB_REPOSITORY,
    GITHUB_REPOSITORY_OWNER,
  } = process.env

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
    url: `https://github.com/${repoName}`,
    branch: altRepo ? GIT_ALT_BRANCH : GITHUB_REF_NAME,
  }
}

export const resolveGitUser = () => {
  const {
    GIT_ALT_REPO,
    GIT_ALT_USER,
    GIT_ALT_EMAIL,
    GITHUB_REPOSITORY,
    GITHUB_REPOSITORY_OWNER,
  } = process.env

  const user = envExists(`GIT_ALT_USER`)
    ? GIT_ALT_USER
    : envExists(`GIT_ALT_REPO`) && GIT_ALT_REPO.includes('/')
      ? GIT_ALT_REPO.split('/').shift()
      : GITHUB_REPOSITORY_OWNER
        ? GITHUB_REPOSITORY_OWNER
        : GITHUB_REPOSITORY
          ? GITHUB_REPOSITORY.split('/').shift()
          : `goblet-action`

  return {
    gitUser: user,
    lastName: `action`,
    firstName: `goblet`,
    email: GIT_ALT_EMAIL || `goblet-action@users.noreply.github.com`,
  }
}
