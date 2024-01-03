import { run } from './run'
import { pull } from './pull'
import { login } from './login'
import { build } from './build'

export const docker = {
  name: `docker`,
  alias: [ `dock`, `doc`, `dc`],
  tasks: {
    build,
    login,
    pull,
    run,
  },
}
