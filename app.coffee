
###
Module dependencies.
###
http = require 'http'
path = require 'path'
fs = require 'fs'

express = require 'express'
partials = require 'express-partials'
flash = require 'connect-flash'
MongoStore = require('connect-mongo') express

settings = require './settings'
routes = require './routes'

accessLogfile = fs.createWriteStream 'logs/access.log', flags: 'a'
errorLogfile = fs.createWriteStream 'logs/error.log', flags: 'a'
app = module.exports = express()

# all environments
app.use express.logger stream: accessLogfile
app.set 'port', process.env.PORT or 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ejs'
app.use partials()
app.use express.favicon()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: settings.cookieSecret
  store: new MongoStore
    db: settings.db
app.use flash()
app.use (req, res, next) ->
  res.locals.user = req.session.user
  err = req.flash 'error'
  res.locals.error = if err.length then err else null
  succ = req.flash 'success'
  res.locals.success = if succ.length then succ else null
  next()
app.use app.router
app.use express.static(path.join(__dirname, 'public'))

# development only
app.use express.errorHandler {dumpExceptions: true, showStack: true}  if 'development' is app.get('env')

# production only
if 'production' is app.get('env')
  app.use (err, req, res, next) ->
    errorLogfile.write "[#{new Date()}] #{req.url}\n#{err.stack}\n"
    next()

routes app

unless module.parent
  app.listen app.get('port'), ->
    console.log 'Express server listening on port %d in %s mode', app.get('port'), app.get('env')
