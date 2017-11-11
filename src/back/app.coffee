express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'

app = express()

app.set 'port', 1337
app.set 'views', "#{__dirname}/../front/views"
app.set 'view engine', 'pug'

app.use '/', express.static "#{__dirname}/../../public"

app.use bodyparser.json()
app.use bodyparser.urlencoded()


# Render index on /
app.get '/', (req, res) ->
  res.render 'index', {}

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"

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

# Start the server
app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"