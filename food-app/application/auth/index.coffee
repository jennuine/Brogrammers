User = require '../models/user.coffee'
Sessions = require './sessions.coffee'
Q = require 'q'

module.exports =
    checkAuth: (req, res, next) ->
        
        if typeof req.session == 'undefined'
            req.user = null
            next()
            return
        
        User.getUser(req.session.username).then((user) ->
            if user.type == 1 or user.type == 3
                user.initStudent()
            else
                Q.Promise.resolve(user)
        ).then((user) ->
            req.user = user
            next()
        )