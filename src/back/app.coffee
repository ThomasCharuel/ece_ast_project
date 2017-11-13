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

# Auth authentication
authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else 
    next()

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

# Get all metrics
app.get '/metrics.json', (req, res) ->
  metrics.get (err, data) ->
    throw next err if err
    res.status(200).json data

# Get a specific metric
app.get '/metrics.json/:id', (req, res) ->
  metrics.getById req.params.id, (err, data) ->
    throw next err if err
    res.status(200).json data

# Post a metric
app.post '/metrics.json/:id', (req, res) ->
  metrics.save req.params.id, req.body, (err) ->
    throw next err if err
    res.status(200).send 'metric saved'

# Delete a metric
app.delete '/metrics.json/:id', (req, res) ->
  metrics.delete req.params.id, (err) ->
    throw next err if err
    res.status(200).send 'metric deleted'

################
# Users Routes
################

user_router = express.Router()

user_router.get '/:username', authCheck, (req, res) ->
  user.get req.params.username, (err, user) ->
    throw next err if err
    if user == null
      res.status(404).send "user not found"
    else res.status(200).json user
    
user_router.post '/', (req, res) ->
  { username, password, email} = req.body.user
  user.save username, password, email, (err) ->
    throw next err if err
    res.status(200).send "user saved"

app.use '/user', user_router

# Start the server
app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"