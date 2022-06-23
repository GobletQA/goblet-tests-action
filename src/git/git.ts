import { runCmd, error } from '@keg-hub/cli-utils'

export const git = async (args: string[], opts: Record<any, any> = {}, ...ext: any[]) => {
  const params = { exec: true, ...opts }
  const resp = await runCmd(`git`, args, params, ...ext)

  return !params.exec
    ? resp
    : resp.exitCode
      ? error.throwError(`[Goblet] Git command error.\n${resp.error}`)
      : resp.data
}
