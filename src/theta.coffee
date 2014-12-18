'use strict'

debug = require('debug')('ricoh-theta')
events = require 'events'

module.exports = class Theta extends events.EventEmitter

  constructor: (@host='192.168.1.1') ->
    @client = require 'ptp'
    debug 'connecting..'
    @client.host = @host
    @client.clientName = 'ricoh-theta npm'

    @client.onDisconnected = =>
      debug 'ptp disconnect'
      @emit 'disconnect'

    @client.onConnected = =>
      debug 'ptp connect'
      @emit 'connect'

    @client.onError = (err) =>
      debug "ptp error - #{err}"
      @emit 'error'

    @client.connect()

  capture: (callback = ->) ->
    @client.capture
      onSuccess: ->
        callback()
      onFailure: ->
        callback 'capture failed'

  list: ->
