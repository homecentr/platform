const reusable = function (context) {
  context.formatMessage = () => {
    const message = `Checking if the page ${this.negate ? 'doesn\'t indicate' : 'indicates'} Pomerium permission rejected`;

    return {
      message,
      args: []
    }
  };

  context.expected = () => {
    return "403 Forbidden"
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
    this.api.getText("div[role=alert]", callback)
  };
};

const assertion = function () {
  reusable(this)
};

module.exports = {
  reusable,
  assertion
}