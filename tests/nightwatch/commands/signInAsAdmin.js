module.exports = {
    command: function () {
        return this.signIn(
            this.globals.admin_user_email,
            this.globals.admin_user_password)
    }
}