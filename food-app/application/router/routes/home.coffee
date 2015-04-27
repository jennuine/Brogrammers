User = require '../../models/user'
Location = require '../../models/location'
Mealplan = require '../../models/mealplan'
Transaction = require '../../models/transaction'
bcrypt = require 'bcryptjs'
Q = require 'q'
zpad = require 'zpad'
sessions = require '../../auth/sessions'

module.exports = 
    get: (req, res) ->
        if req.user and req.user.user_type == 4
            Location.getLocation(req.user.username).then (location) ->
                req.user.location = location
                Transaction.getTransactions(location)
            .then (transactions) ->
                sales =
                    'latest': transactions.slice(-5)
                    'day': (t for t in transactions when t.timestamp > Date.now() - 86400000)
                res.render 'location', {'req': req, 'location': req.user.location, 'sales': sales, 'zpad': zpad}
        else if req.user and req.user.user_type == 5
            Location.getAllLocations().then (locations) ->
                Mealplan.getMealPlans().then (plans) ->
                    res.render 'manager', {'req': req, 'locations': locations, 'plans': plans}
        else if req.user and req.user.user_type == 1
            plans = []
            Mealplan.getMealPlans().then (ps) ->
                plans = ps
                Transaction.getUserTransaction(req.user.username)
            .then (transactions) ->
                res.render 'student', {'req': req, 'plans': plans, 'transactions': transactions.slice(-7), 'zpad': zpad}
        else if req.user and req.user.user_type ==6
            res.render 'public', {'req': req}
        else if req.user and req.user.user_type ==7
            plans = []
            Mealplan.getMealPlans().then (ps) ->
                plans = ps
                Transaction.getUserTransaction(req.user.username)
            .then (transactions) ->
                res.render 'faculty', {'req': req, 'plans': plans, 'transactions': transactions.slice(-7), 'zpad': zpad}
        else
            res.render 'home', {'req': req}
        
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
            offset = if req.query.time == 'week'
                604800000
            else if req.query.time == 'month'
                604800000 * 4
            else if req.query.time == 'day'
                86400000
            else
                Date.now()
            filtered = (t for t in trans when t.timestamp > (Date.now() - offset))
            res.render 'transactions', {'req': req, 'transactions': filtered}
            
    getLocTransactions: (req, res) ->
        Transaction.getTransactions(req.params.location).then (transactions) ->
            res.render 'transactions', {'req': req, 'transactions': transactions}
        
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
        
    getParentPortal: (req, res) ->
        console.log req.session
        res.render 'parents', {'req': req}
        
    postParentPortal: (req, res) ->
        if typeof req.body.email != 'undefined'
            User.getByEmail(req.body.email).then (user) ->
                ssid = sessions.create(res)
                sessions.get(ssid).email = user.email
                res.status(302).set('Location', '/addFunds').end()
        
    getPublic: (req, res) ->
        res.render 'public', {'req': req}
        
    getCPublic: (req, res) ->
        res.render 'createPub', {'req': req}
        
    getStudent: (req, res) ->
        res.render 'student', {'req': req}
        
    getDiningDollars: (req, res) ->
        res.render 'viewDiningDollars', {'req': req}
        
    getMealPlans: (req, res) ->
        #Mealplan.getMealPlans (plans) ->
        res.render 'viewMealPlans', {'req': req}
    
    getAddFunds: (req, res) ->
        res.render 'addFunds', {'req': req}
        
    getSalesReport: (req, res) ->
        locations = []
        Location.getAllLocations().then (locs) ->
            locations = locs
            promises = for location in locs
                Transaction.getTransactions(location).then (transactions) ->
                    Q.all (t.getUser() for t in transactions)
            Q.all(promises)
        .then (transactions) ->
            trans = transactions.reduce (a, b) -> a.concat(b)
            now = Date.now()
            d = 86400000
            w = d * 7
            m = w * 4
            
            day = (t for t in trans when t.timestamp > now - d)
            week = (t for t in trans when t.timestamp > now - w)
            month = (t for t in trans when t.timestamp > now - m)
            
            ykeys = []
            area_data = for i in [0..6]
                today = (t for t in trans when t.timestamp > now - (d * i) and t.timestamp < (now - (d * i)) + d)
                r = 'day': now - (d * i)
                for t in [1..3]
                    today_t = (tr for tr in today when tr.user.user_type == t)
                    today_t.unshift(0)
                    r[t] = today_t.reduce (a, b) -> a + b.price
                r
            donut_data = for k,v of Transaction.Type
                ts = (t for t in trans when t.type == v)
                ts.unshift(0)
                {'label': Transaction.getTypeString(v), 'value': ts.reduce (a, b) -> a + b.price}
            by_location = for loc in locations
                ts = (t for t in trans when t.location.id == loc.id)
                ts.unshift(0)
                {'label': loc.name, 'value': ts.reduce (a, b) -> a + b.price}
            sales = 
                'day': day
                'week': week
                'month': month
                'area_data': () -> JSON.stringify(area_data)
                'donut_data': () -> JSON.stringify(donut_data)
                'by_location': () -> JSON.stringify(by_location)
                'latest': trans.slice(-7)
            User.count().then (user_count) ->
                res.render 'sales', {'req': req, 'sales': sales, 'user_count': user_count, 'zpad': zpad}