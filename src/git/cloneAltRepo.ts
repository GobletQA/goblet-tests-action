import { config } from '@configs/action.config'

export const cloneAltRepo = async () => {
  // TODO: clone the alt git repo
  const { repo, user } = config.git
  console.log(repo, user)
}
