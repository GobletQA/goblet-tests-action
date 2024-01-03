import { docker, error } from '@keg-hub/cli-utils'

/**
 * Sets the docker buildx builder instance
 */
export const setupBuildX = async (
  builder:string,
  appRoot:string,
) => {
  // Create the buildx goblet context if it does not exist
  await docker([
    `buildx`,
    `create`,
    `--name`,
    builder,
    `--platform`,
    `linux/amd64,linux/arm64`,
    `--driver`,
    `docker-container`,
    `--bootstrap`,
  ], {
    cwd: appRoot,
    env: process.env,
    exec: true,
  })

  // Then try to use it, if we don't get an exitCode 0 response, then throw an error
  const { exitCode, ...rest } = await docker([`buildx`, `use`, builder], {
    exec: true,
    cwd: appRoot,
    env: process.env,
  })

  exitCode &&
    error.throwError(
      `Could not switch to buildx context "goblet". Please update the context manually`
    )
}

