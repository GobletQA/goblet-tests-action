import { Logger } from '@keg-hub/cli-utils'

export const exitError = (message: string, exit = 1) => {
  Logger.empty()
  Logger.error(`[Goblet Test Error] Could not complete test execution`)
  message && Logger.log(message)
  Logger.empty()
  console.trace(Logger.colors.red(`Error Stack Trace`))
  Logger.empty()

  process.exit(exit)
}
