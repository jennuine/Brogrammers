Q = require 'q'
sql = require '../sql.coffee'
bcrypt = require 'bcryptjs'
zpad = require 'zpad'

class User
    constructor: (@username, @password, @user_type, id, @name, @email, @pic_path) ->
        @swipes = 0
        @id = zpad(id, 8)
        @user_id = id
        
        
    initStudent: () =>
        future = Q.defer()
        @getSwipes().then(@getDollars).then(@checkPlan).then((user) => future.resolve user)
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
    
    checkPlan: () =>
        future = Q.defer()
        sql.conn.query 'select meal_id from meal_plans where username = ?', [@username], (err, rows, fields) =>
            if err
               @meal_id = 0;
                
            @meal_id = rows[0].meal_id
            
            if @meal_id != 0
                sql.conn.query 'select * from av_meal_plans where id = ?', [@meal_id], (err, rows, fields) =>
                    if err
                        throw err
                    
                    @max_swipe_days = rows[0].days
                    @max_swipes = rows[0].daily_swipes
                    @meal_plan_name = rows[0].name
                    future.resolve @
            else
                @max_swipes = 0
                future.resolve @
        
        return future.promise
        
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
        
    @getTransactions: () =>
        Q.Promis(resolve) ->
            sql.conn.query 'select * from transactions where username = ?', [@username], (err, rows, fields) =>
                if err
                    throw err
                
                trans = for row in rows
                    new trans(row.id, location, row.user, row.type, row.price, row.timestamp)
                resolve trans
        
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
        
    addDollars: (newValue) =>
        future = Q.defer()
        console.log "Adding #{newValue} dollars"
        sql.conn.query 'update dining_dollars set dollars_max = ? where username = ?', [@max_dollars + newValue, @username], (err, rows, fields) =>
            if err
                throw err
            
            @max_dollars += newValue
            future.resolve @
        return future.promise
        
    getLocation: () =>
        return Location.getLocation(@)
        
    getUserPic: (username) ->
        future = Q.defer()
        sql.conn.query 'select user_pic from users where username = ? limit 1', [username], (err, rows, fields) ->
            if err
                throw err
            
            if rows.lengh == 0
                futhur.resolve undefined
                
            @pic_path = rows[0].user_pic
                
            future.resolve @
        return future.promise
        
    @getUser: (username) ->
        future = Q.defer()
        sql.conn.query 'select * from users where username = ? limit 1', [username], (err, rows, fields) ->
            if err
                throw err
                
            if rows.length == 0
                future.resolve undefined
            
            future.resolve new User(rows[0].username, rows[0].password, rows[0].type, rows[0].user_id, rows[0].name, rows[0].email, rows[0].user_pic)

        return future.promise
        
    @getByID: (user_id) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from users where user_id = ?', [user_id], (err, rows, fields) ->
                if err
                    throw err
                
                if rows.length == 0
                    future.resolve undefined
                
                resolve new User(rows[0].username, rows[0].password, rows[0].type, rows[0].user_id, rows[0].name, rows[0].email, rows[0].user_pic)
    
    @getByEmail: (email) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from users where email = ?', [email], (err, rows, fields) ->
                if err
                    throw err
                
                if rows.length == 0
                    future.resolve undefined
                
                resolve new User(rows[0].username, rows[0].password, rows[0].type, rows[0].user_id, rows[0].name, rows[0].email, rows[0].user_pic)

        
    @addUser: (username, password, type, name, email) ->
        hash = bcrypt.hashSync(password, 8)
        Q.Promise (resolve) ->
            sql.conn.query 'insert into users (username, password, type, name, email) values (?,?,?,?,?)', [username, hash, type, name, email], (err, rows, fields) ->
                resolve new User(username, hash, type, row[0].user_id, rows[0].name, rows[0].email, rows[0].user_pic)
                
    @count: () ->
        Q.Promise (resolve) -> 
            sql.conn.query 'select count(*) as user_count from users', (err, rows, fields) ->
                if err
                    throw err
                resolve rows[0].user_count
        
module.exports = User