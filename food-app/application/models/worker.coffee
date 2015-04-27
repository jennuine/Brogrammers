Q = require 'q'
sql = require '../sql.coffee'
Location = require './location'


class Worker

    @getLocation: (user) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from worker_locations where username = ?', [user.username], (err, rows, fields) ->
                if err
                    throw err
                
                Location.getByID(rows[0].loc_id).then (location) -> 
                    resolve location
                    
module.exports = Worker