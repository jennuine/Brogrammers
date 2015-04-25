User = require '../../models/user'
Location = require '../../models/location'
bcrypt = require 'bcryptjs'
sessions = require '../../auth/sessions'

module.exports = 
    get: (req, res) ->
        res.render 'public'