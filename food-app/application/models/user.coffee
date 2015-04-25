Q = require 'q'
sql = require '../sql.coffee'
bcrypt = require 'bcryptjs'

class User
    constructor: (@username, @password, @user_type, @id) ->
        @swipes = 0
        
    initStudent: () =>
        future = Q.defer()
        @getSwipes().then(@getDollars).then((user) => future.resolve user)
        return future.promise
        
    getSwipes: () =>
        future = Q.defer()
        sql.conn.query 'select * from meal_swipes where username = ? limit 1', [@username], (err, rows, fields) =>
            if err
                throw err
                
            if rows.length == 0
                swipes = if @user_type == 1 then 3 else 15
                sql.conn.query 'insert into meal_swipes values (?, ?)', [@username, swipes], (err, rows, fields) =>
                    if err
                        throw err
                        
                    @swipes = swipes
                    future.resolve @
            else
                @swipes = rows[0].swipes
                future.resolve @
        return future.promise
        
    setSwipes: (swipes) =>
        Q.Promise (resolve) =>
            sql.conn.query 'update meal_swipes set swipes = ? where username = ?', [@username, swipes], (err, rows, fields) =>
                if err
                    throw err
                    
                @swipes = swipes
                resolve @
        
    getDollars: () =>
        future = Q.defer()
        sql.conn.query 'select * from dining_dollars where username = ?', [@username], (err, rows, fields) =>
            if err
                throw err
                
            if rows.length == 0
                @dollars = null
                
            else
                @dollars = rows[0].dollars_used
                @max_dollars = rows[0].dollars_max
            future.resolve @
            
        return future.promise
        
    updateSwipes: (newValue) =>
        future = Q.defer()
        sql.conn.query 'update meal_swipes set swipes = ? where username = ?', [newValue, @username], (err, rows, fields) =>
            if err
                throw err
                
            @swipes = newValue
            future.resolve @
        return future.promise
        
    useDollars: (dollars) =>
        return @updateDollars(@dollars + dollars)
        
    updateDollars: (newValue) =>
        future = Q.defer()
        sql.conn.query 'update dining_dollars set dollars_used = ? where username = ?', [newValue, @username], (err, rows, fields) =>
            if err
                throw err
                
            @dollars = newValue
            future.resolve @
        return future.promise
        
    getLocation: () =>
        return Location.getLocation(@)
        
    @getUser: (username) ->
        future = Q.defer()
        sql.conn.query 'select * from users where username = ? limit 1', [username], (err, rows, fields) ->
            if err
                throw err
                
            if rows.length == 0
                future.resolve undefined
            
            future.resolve new User rows[0].username, rows[0].password, rows[0].type, rows[0].id
        return future.promise
        
    @addUser: (username, password, name, type) ->
        hash = bcrypt.hashSync(password, 8)
        Q.Promise (resolve) ->
            sql.conn.query 'insert into users values (?,?,?,?)', [username, hash, type, name], (err, rows, fields) ->
                resolve new User(username, hash, type)
        
module.exports = User