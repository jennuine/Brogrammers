User = require '../../models/user'
Location = require '../../models/location'
Worker = require '../../models/worker'
Transaction = require '../../models/transaction'
express = require 'express'
router = express.Router()
 
userSwipe = (req, res) ->
    username = req.body.username
    if typeof username != 'undefined'
        User.getUser(username).then (user) ->
            if typeof user == 'undefined'
                res.status(404).end()
            
            user.getSwipes().then (user) ->
                user.updateSwipes(user.swipes - 1)
            .then (user) ->
                Worker.getLocation(req.user)
            .then (location) ->
                Transaction.recordTransaction(location, Transaction.Type.SWIPE, 5.0, user)
            .then (transaction) ->
                res.send('{"success": true}')
            
    else
        res.status(400).end()
        
userDollars = (req, res) ->
    username = req.body.username
    if typeof username != 'undefined'
        cur_user = null
        User.getUser(username).then((user) ->
            user.initStudent()
        ).then((user) ->
            user.useDollars(Number(req.body.dollars))
        ).then((user) ->
            cur_user = user
            Worker.getLocation(req.user)
        ).then((location) ->
            Transaction.recordTransaction(location, Transaction.Type.DOLLARS, Number(req.body.dollars), cur_user)
        ).then((transaction) ->
            res.send('{"success": true}')
        )
    else
        res.status(400).end()
        
updateHours = (req, res) ->
    Location.getByID(req.body.loc_id).then (location) ->
        location.updateHours(req.body)
    .then (location) ->
        res.json "success": true
    
    
getTransactions = (req, res) ->
    Location.getByID(req.query.loc_id).then (location) ->
        Transaction.getTransactions(location)
    .then (transactions) ->
        now = Date.now()
        price_time = ([tran.price, (now - tran.timestamp) / 1000] for tran in transactions when now - tran.timestamp < 1800000)
        num_labels = 1800 / 300
        labeled = {}
        for i in [0..num_labels - 1]
            labeled[i] = 0
        for transaction in price_time
            label = Math.floor(transaction[1] / 300)
            labeled[label] = labeled[label] + transaction[0]
        res.json labeled
    
    
router.post '/updateHours', updateHours
router.post '/swipe', userSwipe
router.post '/useDollars', userDollars
router.get '/transactions', getTransactions

module.exports = router