const reusable = function (context) {
  context.formatMessage = () => {
    const message = `Checking if the page ${this.negate ? 'doesn\'t indicate' : 'indicates'} cloudflare permission rejected`;

    return {
      message,
      args: []
    }
  };

  context.expected = () => {
    return "That account does not have access."
  }

  context.value = function (result) {
    return result.value;
  };

  context.failure = function (result) {
    return !result;
  };

  context.evaluate = function (value) {
    return value && value.startsWith(this.expected())
  };

  context.command = async function (callback) {
    this.api.getText("div.AuthBox-messages", callback)
  };
};

const assertion = function () {
  reusable(this)
};

module.exports = {
  reusable,
  assertion
}