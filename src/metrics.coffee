level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db"

module.exports =
  # get (callback)
  # Get metrics
  # - callback: the callback function, callback(err, data)
  get: (callback) ->
    # result array
    res = []
    rs = db.createReadStream()
    # on data, add the data to the result array
    rs.on 'data', (data) ->
      # push new object with id, timestamp and value properties
      res.push 
        id: data.key.split(':')[1]
        timestamp: data.key.split(':')[2]
        value: data.value

    rs.on 'error', (err) -> callback err

    # on stream end, return the result
    rs.on 'end', () ->
      callback null, res

  # getById (id, callback)
  # Get given metrics
  # - id: metric's id
  # - callback: the callback function, callback(err, data)
  getById: (id, callback) ->
    # result array
    res = []
    rs = db.createReadStream()

    # on data and if correct id, add the data to the result array
    rs.on 'data', (data) ->
      # if corresponding id
      if data.key.split(':')[1] == id
        # push new object with id, timestamp and value properties
        res.push 
          id: data.key.split(':')[1]
          timestamp: data.key.split(':')[2]
          value: data.value

    rs.on 'error', (err) -> callback err

    # on stream end, return the result
    rs.on 'end', () ->
      callback null, res


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
  
  # delete (id, callback)
  # Delete given metrics
  # - id: metric id
  # - callback: the callback function
  delete: (id, callback) ->
    ws = db.createWriteStream
      type: 'del'
    ws.on 'error', callback
    ws.on 'close', callback
    ws.write
      key: "metric:#{id}"
    ws.end()
