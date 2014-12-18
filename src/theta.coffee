'use strict'

debug = require('debug')('ricoh-theta')
events = require 'events'

module.exports = class Theta extends events.EventEmitter

  constructor: ->
    @client = require 'ptp'

    @client.onConnected = =>
      debug 'ptp connect'
      @emit 'connect'

    @client.onDisconnected = =>
      debug 'ptp disconnect'
      @emit 'disconnect'

    @client.onError = (err) =>
      debug "ptp error - #{err}"
      @emit 'error'

  connect: (@host='192.168.1.1') ->
    @client.host = @host
    @client.clientName = 'ricoh-theta npm'
    debug 'connecting..'
    @client.connect()
    return @

  disconnect: ->
    @client.disconnect()

  capture: (callback = ->) ->
    @client.capture
      onSuccess: ->
        callback()
      onFailure: ->
        callback 'capture failed'

  getProperty: (code, callback = ->) ->
    @client.getDeviceProperty
      code: code
      onSuccess: (res) ->
        callback null, res
      onFailure: ->
        callback 'getProperty failed'

  getBattery: (callback = ->) ->
    @getProperty @client.devicePropCodes.batteryLevel, callback

  list: ->
