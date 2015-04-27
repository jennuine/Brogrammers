User = require '../models/user.coffee'
Location = require '../models/location'
Sessions = require './sessions.coffee'
Q = require 'q'

module.exports =
    checkAuth: (req, res, next) ->
        
        if typeof req.session == 'undefined' or typeof req.session.username == 'undefined'
            req.user = null
            next()
            return
            
        User.getUser(req.session.username).then((user) ->
            if user.user_type == 1 or user.user_type == 3 or user.user_type == 7
                user.initStudent()
            else if user.user_type == 4
                Location.getLocation(user.username).then (location) ->
                    user.location = location
                    Q.Promise.resolve(user)
            else
                Q.Promise.resolve(user)
        ).then((user) ->
            req.user = user
            next()
        )
        
    logout: (req, res, next) ->
        if req.method == 'POST' and typeof req.body.logout != 'undefined'
            Sessions.destroy(req, res)
            res.status(302).set('Location', '/').end()
        else
            next()