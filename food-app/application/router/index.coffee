express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
Location = require '../models/location'

module.exports = (app) ->
    app.use cookieParser()
    app.use bodyParser.urlencoded(extended: true)
    app.use require('../auth/sessions').addSession
    app.use require('../auth').checkAuth
    
    app.use '/static', express.static "#{__dirname}/../static"
    home = require './routes/home'
    app.get '/', home.get
    app.post '/', home.post
    app.get '/editLocations', home.getEditLocations
    app.post '/editLocations', home.postEditLocations
    app.get '/editLocations/:loc_id', home.getEditLocation
    app.post '/editLocations/:loc_id', home.postEditLocation
    app.get '/editPlans', home.getEditPlans
    app.post '/editPlans', home.postEditPlans
    app.get '/transactions', home.getTransactions
    app.get '/register', require('./routes/register.coffee').get
    
    app.use '/api', require './routes/api'
    
    app.param 'loc_id', (req, res, next, id) ->
        Location.getByID(id).then (location) ->
            req.params.location = location
            next()