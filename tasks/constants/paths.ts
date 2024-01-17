import path from 'node:path'

export const AppRoot = path.join(__dirname, `../../`)

export const DockerfileName = `Dockerfile`
export const Dockerfile = path.join(AppRoot, `./${DockerfileName}`)