User = require '../../models/user'
Location = require '../../models/location'
Mealplan = require '../../models/mealplan'
Transaction = require '../../models/transaction'
bcrypt = require 'bcryptjs'
Q = require 'q'
sessions = require '../../auth/sessions'

module.exports = 
    get: (req, res) ->
        if req.user and req.user.user_type == 4
            Location.getLocation(req.user.username).then (location) ->
                res.render 'location', {'req': req, 'location': location}
        else if req.user and req.user.user_type == 5
            Location.getAllLocations().then (locations) ->
                Mealplan.getMealPlans().then (plans) ->
                    res.render 'manager', {'req': req, 'locations': locations, 'plans': plans}
        else
            res.render 'home', 'req': req
        
    post: (req, res) ->
        if typeof req.body.password != 'undefined'
            username = req.body.username
            password = req.body.password
            User.getUser(username).then (user) ->
                if typeof user == 'undefined'
                    res.status(302).set('Location', '/').end()
                    return
                    
                if bcrypt.compareSync(password, user.password)
                    ssid = sessions.create(res)
                    sessions.get(ssid).username = user.username
                res.status(302).set('Location', '/').end()
        else if typeof req.body.logout != 'undefined'
            sessions.destroy(req, res)
            res.status(302).set('Location', '/').end()
        else
            module.exports.get(req, res)
            
    getEditLocations: (req, res) ->
        Location.getAllLocations().then (locations) ->
            res.render 'editLocations', {'locations': locations, 'req': req}
    
    postEditLocations: (req, res) ->
        if typeof req.body.logout != 'undefined'
            sessions.destroy(req, res)
            res.status(302).set('Location', '/').end()
            return
        else
            futures = []
            for location in req.body.locations
                id = Number(location.id)
                if id == NaN
                    continue
                loc = new Location(id, null, null, null)
                futures.push loc.update(location.manager, location.name)
            Q.all(futures).then () ->
                Location.getAllLocations()
            .then (locations) ->
                res.render 'editLocations', {'req': req, 'locations': locations}
        
    getEditPlans: (req, res) ->
        Mealplan.getMealPlans().then (plans) ->
            res.render 'editPlans', {'plans': plans, 'req': req}
            
    getTransactions: (req, res) ->
        Location.getAllLocations().then (locations) ->
            promises = for location in locations
                Transaction.getTransactions(location)
            Q.all(promises)
        .then (transactions) ->
            trans = transactions.reduce (a, b) -> a.concat(b)
            res.render 'transactions', {'req': req, 'transactions': trans}
        
    postEditPlans: (req, res) ->
        if typeof req.body.logout != 'undefined'
            sessions.destroy(req, res)
            res.status(302).set('Location', '/').end()
            return
        else
            futures = []
            for plan in req.body.plans
                id = Number(plan.id)
                if id == NaN
                    continue
                console.log plan
                mealplan = new Mealplan(id, undefined, undefined, undefined, undefined)
                f = mealplan.update(plan.name, plan.daily_swipes, plan.days, plan.swipes)
                futures.push(f)
            Q.all(futures).then () ->
                Mealplan.getMealPlans()
            .then (plans) ->
                res.render 'editPlans', {'plans': plans, 'req': req}
                
    getEditLocation: (req, res) ->
        res.render 'location', {'req': req, 'location': req.params.location}
        
    postEditLocation: (req, res) ->
        res.render 'location', {'req': req, 'location': req.params.location}