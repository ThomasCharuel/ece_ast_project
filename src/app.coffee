express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'

app = express()

app.set 'port', 1337
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use '/', express.static "#{__dirname}/../public"

app.use bodyparser.json()
app.use bodyparser.urlencoded()


# Render index on /
app.get '/', (req, res) ->
  res.render 'index', {}

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"

app.get '/metrics.json', (req, res) ->
  metrics.get (err, data) ->
    throw next err if err
    res.status(200).json data

app.post '/metrics.json/:id', (req, res) ->
  metrics.save req.params.id, req.body, (err) ->
    throw next err if err
    res.status(200).send 'metrics saved'

app.put '/', (req, res) ->
  # PUT

app.delete '/', (req, res) ->
  # DELETE

app.listen app.get('port'), () ->
  console.log "server listening on #{app.get 'port'}"