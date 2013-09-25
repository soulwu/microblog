
###
Module dependencies.
###
express = require 'express'

routes = require './routes'
http = require 'http'
path = require 'path'
settings = require './settings'

partials = require 'express-partials'
flash = require 'connect-flash'
MongoStore = require('connect-mongo') express

app = express()

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ejs'

app.use partials()

app.use express.favicon()

app.use express.logger('dev')

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
app.use express.errorHandler() if 'production' is app.get('env')

routes app

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port %d in %s mode', app.get('port'), app.get('env')

