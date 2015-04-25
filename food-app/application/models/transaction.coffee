Q = require 'q'
sql = require '../sql'

class Transaction
    @Type:
        SWIPE: 1,
        CASH: 2,
        CREDIT: 3,
        DOLLARS: 4
    
    constructor: (@id, @location, @user, @type, @price, @timestamp) ->
        @date = new Date(@timestamp)
        @type_string = (() =>
            for k, v of Transaction.Type
                if Transaction.Type[k] == @type
                    return k
        )()
        
        
    @getTransactions: (location) ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from transactions where loc_id = ?', [location.id], (err, rows, fields) ->
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
                
                
module.exports = Transaction