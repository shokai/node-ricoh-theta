'use strict'

debug  = require('debug')('ricoh-theta')
events = require 'events'
ptp    = require 'ptp'

module.exports = class Theta extends events.EventEmitter

  constructor: ->
    @client = ptp

    @client.onConnected = =>
      debug 'ptp connect'
      @emit 'connect'

    @client.onDisconnected = =>
      debug 'ptp disconnect'
      @emit 'disconnect'

    @client.onError = (err) =>
      debug "ptp error - #{err}"
      @emit 'error'

    ## register device property methods
    for name, code of ptp.devicePropCodes
      do (name, code) =>
        method_name = "get#{name[0].toUpperCase()}#{name[1..-1]}"
        @[method_name] = (callback = ->) =>
          debug "get property \"#{method_name}\" - code: #{code}"
          @getProperty code, callback

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
        name = ptp.devicePropCodes[code] or 'undefined'
        callback 'getting property \"#{name}\" was failed'

  list: ->
