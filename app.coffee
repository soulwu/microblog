
###
Module dependencies.
###
express = require 'express'
partials = require 'express-partials'
routes = require './routes'
http = require 'http'
path = require 'path'
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
app.use app.router
app.use express.static(path.join(__dirname, 'public'))

# development only
app.use express.errorHandler {dumpExceptions: true, showStack: true}  if 'development' is app.get('env')
app.use express.errorHandler() if 'production' is app.get('env')

app.get '/', routes.index
app.get '/u/:user', routes.user
app.post '/post', routes.post
app.get '/reg', routes.reg
app.post '/reg', routes.doReg
app.get '/login', routes.login
app.post '/login', routes.doLogin
app.get '/logout', routes.logout

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port %d in %s mode', app.get('port'), app.get('env')

