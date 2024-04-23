module.exports = {
  command: function (subdomain) {
      return this.url(`https://${subdomain}${this.globals.domainSuffix}`)
  }
}