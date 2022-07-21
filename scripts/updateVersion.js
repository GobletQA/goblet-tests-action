const fs = require('fs')
const path = require('path')
// const actionYmlLoc = path.join(__dirname, `../action.yml`)
const packConfLoc = path.join(__dirname, `../package.json`)
const packConf = require(packConfLoc)

// TODO: load actionYml file here
const actionYml = {}

;(() => {

  // const packVer = packConf.version
  // const actionVer = actionYml.version
  const args = process.argv.slice(2)
  const newVer = args.pop() || `bump`
  if(newVer === `bump`){
    
  }

})()