sql = require '../sql'
Q = require 'q'

class Mealplan
    constructor: (@id, @name, @daily_swipes, @days, @swipes, @sales) ->

    update: (name, daily_swipes, days, swipes) =>
        Q.Promise (resolve) =>
            sql.conn.query 'update av_meal_plans set name = ?, daily_swipes = ?, days = ?, swipes = ? where id = ?',
            [name, daily_swipes, days, swipes, @id], (err, rows, fields) =>
                if err
                    throw err
                    
                @name = name
                @daily_swipes = daily_swipes
                @days = days
                @swipes = swipes
                resolve @
    
    @getMealPlans: () ->
        Q.Promise (resolve) ->
            sql.conn.query 'select * from av_meal_plans', (err, rows, fields) ->
                if err
                    throw err
                
                resolve (new Mealplan(row.id, row.name, row.daily_swipes, row.days, row.swipes, row.sales) for row in rows)
                
module.exports = Mealplan