const isPomeriumPermissionRejectedPage = require("./isPomeriumPermissionRejectedPage")
const isCloudflarePermissionRejectedPage = require("./isCloudflarePermissionRejectedPage")

const assertion = function () {
  if (this.__nightwatchInstance.settings.globals.isRemote) {
    isCloudflarePermissionRejectedPage.reusable(this)
  } else {
    isPomeriumPermissionRejectedPage.reusable(this)
  }
}

module.exports = {
  assertion
}