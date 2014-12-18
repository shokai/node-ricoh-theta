'use strict'

debug = require('debug')('ricoh-theta')
events = require 'events'

module.exports = class Theta extends events.EventEmitter

  constructor: ->
    @client = require 'ptp'

    @client.onDisconnected = =>
      debug 'ptp disconnect'
      @emit 'disconnect'

    @client.onConnected = =>
      debug 'ptp connect'
      @emit 'connect'

    @client.onError = (err) =>
      debug "ptp error - #{err}"
      @emit 'error'

  connect: (@host='192.168.1.1') ->
    @client.host = @host
    @client.clientName = 'ricoh-theta npm'
    debug 'connecting..'
    @client.connect()
    return @

  capture: (callback = ->) ->
    @client.capture
      onSuccess: ->
        callback()
      onFailure: ->
        callback 'capture failed'

  list: ->
