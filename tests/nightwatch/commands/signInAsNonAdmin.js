module.exports = {
    command: function () {
        return this.signIn(
            this.globals.nonadmin_user_email,
            this.globals.nonadmin_user_password)
    }
}