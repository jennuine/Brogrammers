Q = require 'q'
sql = require '../sql'
User = require './user.coffee'
Location = require './location'

class Transaction
    @Type:
        SWIPE: 1,
        CASH: 2,
        CREDIT: 3,
        DOLLARS: 4
    
    constructor: (@id, @location, @username, @type, @price, @timestamp) ->
        @date = new Date(@timestamp)
        @type_string = Transaction.getTypeString(@type)
        
    getUser: () =>
        User.getUser(@username).then (user) =>
            @user = user
            Q.Promise.resolve(@)
            
    getLocation: (loc_id) =>
        Q.Promise (resolve) =>
            Location.getByID(loc_id).then (location) =>
                @location = location
                resolve @
            
    @getUserTransaction: (username) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from transactions where user = ? order by timestamp desc', [username], (err, rows, fields) ->
                if err
                    throw err
                    
                userTransactions = for row in rows
                    new Transaction(row.id, null, username, row.type, row.price, row.timestamp).getLocation(row.loc_id)
                Q.all(userTransactions).then (transactions) -> resolve transactions
        
    @getTransactions: (location) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from transactions where loc_id = ? order by timestamp desc', [location.id], (err, rows, fields) ->
                if err
                    throw err
                    
                transactions = for row in rows
                    new Transaction(row.id, location, row.user, row.type, row.price, row.timestamp)
                resolve transactions
                
    @recordTransaction: (location, type, price, user) ->
        Q.Promise (resolve) ->
            sql.conn.query 'insert into transactions values (default, ?, ?, ?, ?, ?)', [location.id, user.username, type, Date.now(), price], (err, rows, fields) ->
                if err
                    throw err
                    
                resolve new Transaction(location, user.username, type, price, Date.now())
                
    @getTypeString: (type) ->
        if type == Transaction.Type.SWIPE
            'Swipe'
        else if type == Transaction.Type.CASH
            'Cash'
        else if type == Transaction.Type.CREDIT
            'Credit Card'
        else
            'Dining Dollars'
                
module.exports = Transaction