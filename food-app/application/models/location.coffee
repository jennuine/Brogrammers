Q = require 'q'
sql = require '../sql.coffee'
user = require './user.coffee'

class Location
    constructor: (@id, @hours, @manager, @name) ->
        
    updateHours: (hours) =>
        Q.Promise (resolve) =>
            sql.conn.query 'update locations set hours = ? where id = ?', [JSON.stringify(hours), @id], (err, rows, fields) ->
                if err
                    throw err
                    
                @hours = hours
                resolve @
                
    update: (manager, name) =>
        Q.Promise (resolve) =>
            sql.conn.query 'update locations set manager = ?, name = ? where id = ?', [manager, name, @id], (err, rows, fields) ->
                if err
                    throw err
                    
                @manager = manager
                @name = name
                resolve @
        
    @getLocation: (manager) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from locations where manager = ?', [manager], (err, rows, fields) ->
                if err
                    throw err
                if rows.length == 0
                    resolve undefined
                else
                    resolve new Location(rows[0].id, JSON.parse(rows[0].hours), manager, rows[0].name)
                    
    @getManagerInfo: () ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from users where username = ?', [@manager], (err, rows, fields) ->
                if err
                    throw err
                if rows.length == 0
                    resolve undefined
                else
                    user.getUser(@manager).then (user)
                    resolve user
                    
    @add: (location) ->
        Q.Promise (resolve) ->
            sql.conn.query 'insert into locations values (default, ?, ?, ?, ?)', 
            [location.manager, location.name, JSON.stringify(location.hours)], (err, rows, fields) ->
                if err
                    throw err
                    
                sql.conn.query 'select last_insert_id() as id', (err, rows, fields) ->
                    if err
                        throw err
                        
                    location.id = rows[0].id
                    resolve location
                    
    @getByID: (id) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from locations where id = ?', [id], (err, rows, fields) ->
                if err
                    throw err
                    
                if rows.length == 0
                    resolve undefined
                else
                    resolve new Location(rows[0].id, JSON.parse(rows[0].hours), rows[0].manager, rows[0].name)
    
    @getAllLocations: () ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from locations', (err, rows, fields) ->
                if err
                    throw err
                    
                resolve (new Location(row.id, JSON.parse(row.hours), row.manager, row.name) for row in rows)
    
module.exports = Location