describe('Proxmox VE when accessed locally should', () => {
  this.tags = [ "localonly" ]

  afterEach((browser) => {
    browser.end()
  })

  it('Load main screen after signing in as admin', (browser) => {
    browser
      .subdomain('pve')
      .setValue('#pveloginrealm-inputEl', 'Azure Active Directory')
      .waitForElementVisible("a#button-1070")
      .click('a#button-1070')  // Redirects to AAD
      .signInAsAdmin()
      .assert.textContains("#versioninfo-innerCt", "Virtual Environment")
  });

  it('Not allow non-admins to use the app', (browser) => {
    browser
      .subdomain('pve')
      .setValue('#pveloginrealm-inputEl', 'Azure Active Directory')
      .waitForElementVisible("a#button-1070")
      .click('a#button-1070') // Redirects to AAD
      .signInAsNonAdmin()
      .pause(6000)
      .assert.isAadPermissionRejectedPage()
  });
});
