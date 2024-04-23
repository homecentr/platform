const { decryptSops } = require('sops-wrapper');
const dotenv = require("dotenv");
const fs = require("fs");
const dns = require("dns");

module.exports = {
  beforeEach(done) {
    console.log("Loading secrets via SOPS...")

    const secrets = decryptSops(`./tests/environments/${this.secretsFile}`)
    
    // Expose env file and secrets as globals
    Object.assign(this, secrets)

    // Set DNS from env file
    const envFile = dotenv.parse(fs.readFileSync(`./tests/environments/${this.envFile}`))
    console.log(envFile)
    dns.setServers([ envFile.DNS1, envFile.DNS2 ])

    done()
  }
}