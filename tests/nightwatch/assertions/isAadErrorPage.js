const reusable = function (context, errorCode) {
  context.formatMessage = () => {
    const message = `Checking if the page ${this.negate ? 'doesn\'t indicate' : 'indicates'} AAD error code %s`;

    return {
      message,
      args: [`'${errorCode}'`]
    }
  };

  context.expected = () => {
    return errorCode
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
    this.api.getText("#exceptionMessageContainer", callback)
  };
};

const assertion = function (errorCode) {
  reusable(this, errorCode)
};

module.exports = {
  reusable,
  assertion
}