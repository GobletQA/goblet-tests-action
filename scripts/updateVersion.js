const path = require('path')
const yaml = require('js-yaml')
const semver = require('semver')
const { readFileSync, writeFileSync } = require('fs')

const actionYmlLoc = path.join(__dirname, `../action.yml`)
const actionYml = yaml.load(readFileSync(actionYmlLoc).toString())

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
  const [proto, repo] = actionYml.runs.image.split(`:`)
  actionYml.runs.image = `${proto}:${repo}:${version}`
  const [content, inputs] = yaml.dump(actionYml, {
    noRefs: true,
    lineWidth: -1,
  })
    .split(`runs:`)
    .join(`\nruns:`)
    .split(`args:\n`)
  
  const data = inputs.split(`\n`).reduce((acc, line, idx) => {
    if(!line.trim()) return acc

    // Remove quotes that get added in parsing
    const cleaned = line.replaceAll(`'`, ``)
    // Add the input index comments back so they can be tracked
    acc += `${cleaned} #${idx + 1}\n`

    return acc
  }, `${content}args:\n`)

  writeFileSync(actionYmlLoc, `# action.yml\n${data}`)
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

  console.log(`Updating version to ${version}\n`)

  await updatePackageVersion(version)
  await updateActionImageTag(version)

  console.log(`Version was updated to ${version}\n`)

})()