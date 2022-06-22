import { cloneAltRepo } from './cloneAltRepo'
import { config } from '@configs/action.config'

export const getRepoDir = async () => {
  config.git.altRepo && (await cloneAltRepo())
  // TODO: set the needed repo values
}
