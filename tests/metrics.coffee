{exec} = require 'child_process'
should = require 'should'

describe "metrics", () ->

  metrics = null
  before (next) ->
    exec "rm -rf #{__dirname}/../db/*", (err, stdout) ->
      db = require('../src/back/db')("#{__dirname}/../db/data")
      metrics = require('../src/back/metrics')(db)
      next err

  it "get a metric", (next) ->
    ## Create dummy data to then get
    metrics.save '1', [
      timestamp:(new Date '2015-11-04 14:00 UTC').getTime(),
      value: 23,
      timestamp:(new Date '2015-11-04 14:10 UTC').getTime(),
      value: 56
    ], "test", (err) ->
      return next err if err
      metrics.getById '1', (err, metrics) ->
        return next err if err
        # do some tests here on the returned metrics
        next()
