const isAadErrorPage = require("./isAadErrorPage")

const reusable = function (context) {
  isAadErrorPage.reusable(context, "AADSTS50105")
}

const assertion = function () {
  reusable(this)
};

module.exports = {
  reusable,
  assertion
}