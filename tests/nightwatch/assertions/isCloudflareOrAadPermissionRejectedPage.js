const isAadPermissionRejectedPage = require("./isAadPermissionRejectedPage")
const isCloudflarePermissionRejectedPage = require("./isCloudflarePermissionRejectedPage")

const assertion = function () {
  if (this.__nightwatchInstance.settings.globals.isRemote) {
    isCloudflarePermissionRejectedPage.reusable(this)
  } else {
    isAadPermissionRejectedPage.reusable(this)
  }
}

module.exports = {
  assertion
}