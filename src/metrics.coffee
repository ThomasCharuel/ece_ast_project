level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db"

module.exports =
  ###
    `get(callback)`
    ———————
    returns some hard-coded metrics

    `callback`: callback function
  ###

  get: (callback) ->
    callback null, [
      timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value: 12
    ,
      timestamp:(new Date '2013-11-04 14:30 UTC').getTime(), value: 15
    ]
  
  save: (id, metrics, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    for metric in metrics
      {timestamp, value} = metric
      ws.write key: "metric:#{id}:#{timestamp}", value: value
    ws.end()