express = require 'express'
bodyparser = require 'body-parser'
morgan = require 'morgan'
session = require 'express-session'
SessionStore = require('level-session-store')(session)

db = require('./db')("#{__dirname}/../../db/data")

metrics = require('./metrics')(db)
user = require('./user')(db)

app = express()

app.set 'port', 1337
app.set 'views', "#{__dirname}/../front/views"
app.set 'view engine', 'pug'

app.use '/', express.static "#{__dirname}/../../public"

app.use bodyparser.json()
app.use bodyparser.urlencoded()
app.use morgan 'dev'
app.use session
  secret: "simple secret"
  store: new SessionStore './db/sessions'
  resave: true
  saveUninitialized: true

################
# Authentication
################
authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else 
    next()

################
# Auth routes
################
app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res) ->
  {username, password} = req.body
  user.get username, (err, user) ->
    throw next err if err
    unless password == user.password
      res.redirect '/login'
    else
      req.session ?= {}
      req.session.loggedIn = true
      req.session.username = user.username
      res.redirect '/'

app.get '/signup', (req, res) ->
  res.render 'signup'

app.post '/signup', (req, res) ->
  {username, password, email} = req.body
  user.save username, password, email, (err) ->
    throw next err if err
    res.redirect '/login'

app.get '/logout', authCheck, (req, res) ->
  delete req.session.loggedIn
  delete req.session.username
  res.redirect '/login'

# Render index on /
app.get '/', authCheck, (req, res) ->
  res.render 'index', name: req.session.username

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"

################
# Metrics Routes
################

metrics_router = express.Router()
metrics_router.use authCheck

# Get all metrics
metrics_router.get '', (req, res) ->
  metrics.get req.session.username, (err, data) ->
    throw next err if err
    res.status(200).json data

# Get a specific metric
metrics_router.get '/:id', (req, res) ->
  metrics.getById req.params.id, req.session.username, (err, data) ->
    throw next err if err
    res.status(200).json data

# Post a metric
metrics_router.post '/:id', (req, res) ->
  metrics.save req.params.id, req.body, req.session.username, (err) ->
    throw next err if err
    res.status(200).send 'metric saved'

# Delete a metric
metrics_router.delete '/:id', (req, res) ->
  metrics.delete req.params.id, req.session.username, (err) ->
    throw next err if err
    res.status(200).send 'metric deleted'

app.use '/metrics.json', metrics_router

################
# Users Routes
################

user_router = express.Router()

# Get a specific user
user_router.get '/:username', authCheck, (req, res) ->
  user.get req.params.username, (err, user) ->
    throw next err if err
    if user == null
      res.status(404).send "user not found"
    else res.status(200).json user
    
# Post a user
user_router.post '/', (req, res) ->
  { username, password, email} = req.body.user
  user.save username, password, email, (err) ->
    throw next err if err
    res.status(200).send "user saved"

# Delete a user
user_router.delete '/', authCheck, (req, res) ->
  user.remove req.session.username, (err) ->
    throw next err if err
    res.status(200).send 'user deleted'

app.use '/user', user_router

# Start the server
app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"