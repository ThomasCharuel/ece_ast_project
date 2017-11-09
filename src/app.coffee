express = require 'express'

metrics = require './metrics'

app = express()

app.set 'port', 1337
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use '/', express.static "#{__dirname}/../public"

# Render index on /
app.get '/', (req, res) ->
  res.render 'index', {}

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"

app.get '/metrics.json', (req, res) ->
  metrics.get (err, data) ->
    throw next err if err
    res.status(200).json data

app.post '/', (req, res) ->
  # POST

app.put '/', (req, res) ->
  # PUT

app.delete '/', (req, res) ->
  # DELETE

app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"