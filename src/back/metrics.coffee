module.exports = (db) ->
  # get (callback)
  # Get metrics
  # - username: the user id
  # - callback: the callback function, callback(err, data)
  get: (username, callback) ->
    # result array
    res = []
    rs = db.createReadStream()
    # on data, add the data to the result array
    rs.on 'data', (data) ->
      [ ..., dataUsername, dataId, dataTimestamp ] = data.key.split ":"
      if username == dataUsername
        # push new object with id, timestamp and value properties
        res.push 
          id: dataId
          timestamp: dataTimestamp
          value: data.value

    rs.on 'error', (err) -> callback err

    # on stream end, return the result
    rs.on 'end', () ->
      callback null, res

  # getById (id, callback)
  # Get given metrics
  # - id: metric's id
  # - username: the user id
  # - callback: the callback function, callback(err, data)
  getById: (id, username, callback) ->
    # result array
    res = []
    rs = db.createReadStream()

    # on data and if correct id, add the data to the result array
    rs.on 'data', (data) ->
      [ ..., dataUsername, dataId, dataTimestamp ] = data.key.split ":"
      # if corresponding id
      if dataId == id and username == dataUsername
        # push new object with id, timestamp and value properties
        res.push 
          id: dataId
          timestamp: dataTimestamp
          value: data.value

    rs.on 'error', (err) -> callback err

    # on stream end, return the result
    rs.on 'end', () ->
      callback null, res


  # save (id, metrics, callback)
  # Save given metrics
  # - id: metric id
  # - metrics: an array of { timestamp, value }
  # - username: the user id
  # - callback: the callback function
  save: (id, metrics, username, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', (err) -> callback err
    ws.on 'close', callback
    for metric in metrics
      { timestamp, value } = metric
      ws.write 
        key: "metric:#{username}:#{id}:#{timestamp}"
        value: value
    ws.end()
  
  # delete (id, callback)
  # Delete given metrics
  # - id: metric id
  # - username: the user id
  # - callback: the callback function
  delete: (id, username, callback) ->
    # array of keys for db items to delete
    keys = []

    rs = db.createKeyStream()
    rs.on 'error', (err) -> callback err
    rs.on 'data', (key) ->
      # Split the key
      [ keyTable, dataUsername, dataId ] = data.key.split ":"

      # add the key to the key array if the key starts with "metric:{id}"
      if keyTable == 'metric' and dataId == id and username == dataUsername
        # Add the key to the list of items to delete
        keys.push key
    
    # When every key has been streamed
    rs.on 'end', () ->
      # Open new stream to delete items
      ws = db.createWriteStream
        type: 'del'
      ws.on 'error', (err) -> callback err
      ws.on 'close', callback
      
      # For each key of items to delete
      for key in keys
        # Delete the item
        ws.write
          key: key
      
      ws.end()
