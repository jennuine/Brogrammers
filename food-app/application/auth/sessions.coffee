crypto = require 'crypto'

sessions = {}

module.exports = 
    get: (id) ->
        return sessions[id]
    create: (res) ->
        ssid = crypto.createHash('sha1').update(crypto.randomBytes(32)).digest('hex')
        sessions[ssid] = {}
        res.cookie 'session', ssid, {maxAge: 604800000}
        
        return ssid
    destroy: (req, res) ->
        delete sessions[req.cookies.session]
        res.clearCookie('session')
    addSession: (req, res, next) ->
        req.session = undefined
        if typeof req.cookies.session == 'undefined'
            next()
            return
        req.session = sessions[req.cookies.session]
        next()