express = require 'express'
router = require './application/router'
swig = require 'swig'
fs = require 'fs'

app = express()

app.engine 'html', swig.renderFile
app.set 'view engine', 'html'
app.set 'views', __dirname + '/application/templates'

router app 

server = app.listen(process.env.PORT, process.env.IP)
