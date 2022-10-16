const path = require('path')
const yaml = require('js-yaml')
const semver = require('semver')
const { readFileSync, writeFileSync } = require('fs')
const { writeYml } = require('@keg-hub/parse-config')

const actionYmlLoc = path.join(__dirname, `../action.yml`)
const actionYml = yaml.safeLoad(readFileSync(actionYmlLoc).toString())

const packConfLoc = path.join(__dirname, `../package.json`)
const packConf = require(packConfLoc)

const SEMVER_TYPES = [
  'major',
  'minor',
  'patch',
  'meta',
  `premajor`,
  `preminor`,
  `prepatch`,
  `prerelease`,
]

const invalidVersionErr = (version) => {
  throw new Error(`The version ${version} is not a valid semver version.`)
}

const updatePackageVersion = async (version) => {
  packConf.version = version
  writeFileSync(packConfLoc, `${JSON.stringify(packConf, null, 2)}\n`)
}

const updateActionImageTag = async (version) => {
  const [proto, repo, tag] = actionYml.runs.image.split(`:`)
  actionYml.runs.image = `${proto}:${repo}:${version}`
  await writeYml(actionYmlLoc, actionYml)
}

const updateVersion = (oldVersion, newVersion) => {
  return SEMVER_TYPES.includes(newVersion)
    ? semver.inc(oldVersion, newVersion)
    : semver.valid(newVersion)
      ? newVersion
      : invalidVersionErr(newVersion)
}

;(async () => {

  const args = process.argv.slice(2)
  const newVersion = args.pop() || `patch`
  const oldVersion = packConf.version

  const version = updateVersion(oldVersion, newVersion)

  console.log(`Updating version to ${version} ...`)

  await updatePackageVersion(version)
  await updateActionImageTag(version)

  console.log(`Version was updated to ${version}`)

})()