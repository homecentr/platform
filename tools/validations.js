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

    if(fileName.match(/pve\d\.y(a)?ml/)) {
      return [
        // Managed manually in prod due to bonded NICs
        "pve_network_interfaces"
      ]
    }

    if(fileName.match(/kube\d\.y(a)?ml/)) {
      return [
        // Drivers depend on hardware configuration which differs across environments
        "nvidia_drivers_driver_package_name"
      ]
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
  process.exitCode = 1

  differences.forEach(difference => {
    console.log(`❌ ${difference.message}`)
  })
}