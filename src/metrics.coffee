level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db"

module.exports =
  # get (id, callback)
  # Get metrics
  # - id: metric's id
  # - callback: the callback function, callback(err, data)
  get: (callback) ->
    callback null, [
      timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:12
    ,
        timestamp:(new Date '2013-11-04 14:30 UTC').getTime(), value:15
    ]
  getById: (id, callback) ->
    callback null, [
      timestamp: (new Date '2018-11-09 15:00 UTC').getTime(), value: 1
    ]

  # save (id, metrics, callback)
  # Save given metrics
  # - id: metric id
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (id, metrics, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    for metric in metrics
      { timestamp, value } = metric
      ws.write 
        key: "metric:#{id}:#{timestamp}"
        value: value
    ws.end()