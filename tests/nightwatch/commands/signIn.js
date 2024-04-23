module.exports = {
  command: function (email, password) {
    return this
      // E-mail
      .setValue("input[type=email]", email)
      .click('input[type=submit]')

      // Password
      .waitForElementVisible("css selector", "input[type=password].form-control") // Checking the e-mail may take a few seconds
      .setValue("input[type=password].form-control", password)
      .click("input[value='Sign in']")
      // Wait for the Sign in button to disappear
      .waitForElementNotPresent("input[value='Sign in']", 2000)
      // Check whether the "Stay signed in?" page was shown
      .isPresent({
          suppressNotFoundErrors: true,
          selector: "input[type=button][value=No]",
          timeout: 1000
        },
        result => {
          if (result.status > -1) {
            this.click("input[type=button][value=No]")
          }
        })
  }
}