const {
  diffDirs
} = require("@homecentr/yaml-diff")

const options = {
  fileNameGlob: "**/*.{yml,yaml}",
  sopsFilesGlob: "**/*.sops.{yml,yaml}",
  ignoreListFunc: (fileName) => {
    if(fileName == "hosts.yml") {
      return true
    }
    
    return []
  }
}

const differences = diffDirs(
  "./environments/lab",
  "./environments/prod",
  options)

if (differences.length == 0) {
  console.log(`✔️ All files have matching structures`)
} else {
  differences.forEach(difference => {
    console.log(`❌ ${difference.message}`)
  })
}