const nodemailer = require("nodemailer");
const dnsPromises = require("dns").promises

describe('Mailrelay when accessed locally should', async () => {
  this.tags = ["localonly"]

  it('Send e-mail', async (browser) => {
    const smtpHostname = `smtp${browser.globals.domainSuffix}`
    const smtpIp = await dnsPromises.resolve(smtpHostname, "A")

    const transport = nodemailer.createTransport({
      host: smtpIp[0],
      port: 25,
      auth: {
        user: browser.globals.smtp_relay_username,
        pass: browser.globals.smtp_relay_password
      },
      tls: {
        // Server has only domain in certificate and we are using a direct ip to skip dns resolution
        servername: smtpHostname
      }
    });

    const receipt = await transport.sendMail({
      from: browser.globals.smtp_relay_sender,
      to: browser.globals.smtp_relay_recipient,
      subject: "E2E test ✔",
      text: "Hello, world!"
    });

    expect(receipt.accepted.length).to.be.equal(1)
  });
});