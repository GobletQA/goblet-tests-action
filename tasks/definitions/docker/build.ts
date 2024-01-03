import type { TTask, TTaskActionArgs } from '../../types'
import {
  AppRoot,
  DockerImageName,
  DockerBuildxBuilder
} from '../../constants'

import { isStr } from '@keg-hub/jsutils/isStr'

import { getNpmToken } from '../../utils/getNpmToken'
import { setupBuildX } from '../../utils/setupBuildX'

const buildImg = async (args:TTaskActionArgs) => {
  const { params } = args
  const {
    env,
    log,
    from,
    login,
    image,
    registry,
    builder,
    context,
  } = params

  const token = getNpmToken()
  builder && (await setupBuildX(isStr(builder) ? builder : DockerBuildxBuilder, AppRoot))
  const imageName = image || DockerImageName

  // const registryUrl = registry || imageName.split('/').shift()
  // login && await docker.login(token, registryUrl)

}

export const build:TTask = {
  name: `build`,
  action: buildImg,
  alias: [`bd`, `bld`],
  options: {
    local: {
      type: `boolean`,
      default: false,
      description: `Only build the image locally, do not push to remote registry`,
    },
    push: {
      type: `boolean`,
      default: false,
      description: `Push the built image to the docker provider. Always false if local option is true`,
    },
    tag: {
      type: `array`,
      alias: [`tags`],
      example: `--tag tag-1,tag-2`,
      description: `Name of the tag to add to the built Docker image`,
    },
    registry: {
      alias: [`reg`],
      default: `ghcr.io/gobletqa`,
      example: `--reg my.docker.registry`,
      description: `URL of the docker image registry to use`,
    },
    image: {
      env: `GB_ACT_IMAGE`,
      description: `Name of the docker image to be built. Used when tagging`,
    },
    force: {
      default: true,
      type: `boolean`,
      description: `Force remove temporary images used while building`,
    },
    log: {
      type: `boolean`,
      description: `Log command before they are build`,
    },
    builder: {
      default: DockerBuildxBuilder,
      description: `Name of the docker buildx builder instance to use`,
    },
    cache: {
      type: `boolean`,
      default: true,
      description: `User docker cache when building the image`,
    },
    platforms: {
      type: `array`,
      default: [`linux/amd64`, `linux/arm64`],
      description: `List of docker platforms to be built`,
    },
    login: {
      default: true,
      type: `boolean`,
      alias: [`auth`],
      example: `--no-login`,
      description: `Log into the docker registry before building the image. Typically used along side the push option`,
    }
  },
}
