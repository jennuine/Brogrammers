mysql = require 'mysql'

connection = mysql.createPool({
    host: 'localhost',
    user: 'food',
    password: 'password',
    database: 'food_app'
})

module.exports.conn = connection