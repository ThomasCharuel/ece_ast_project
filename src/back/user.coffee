module.exports = (db) ->
  get: (username, callback) ->
    db.get "user:#{username}", (err, data) ->
      throw err if err
      [ password, email ] = data.split ":"
      result = 
        username: username
        password: password
        email: email
      callback null, result

  save: (username, password, email, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback

    ws.write
      key: "user:#{username}"
      value: "#{password}:#{email}"
    ws.end()

  remove: (username, callback) ->