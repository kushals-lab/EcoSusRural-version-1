class User {
    constructor(id, email, role = 'farmer') {
        this.id = id;
        this.email = email;
        this.role = role;
    }
}
module.exports = User;