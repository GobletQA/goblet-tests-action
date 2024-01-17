import path from 'node:path'
import { tasks } from './definitions'
import { ife } from '@keg-hub/jsutils'
import { setAppRoot, runTask } from '@keg-hub/cli-utils'

ife(async () => {
  setAppRoot(path.join(__dirname, `../`))
  
  await runTask(tasks, { env: process.env.NODE_ENV || 'local' })
})

