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
    @client.onObjectAdded = (res) =>
      object_id = res.parameters?[1]
      debug "objectAdded: #{object_id}"
      @emit 'objectAdded', object_id
    return @

  disconnect: ->
    @client.disconnect()

  capture: (callback = ->) ->
    debug "request capture"
    @client.capture
      onSuccess: ->
        callback null
      onFailure: ->
        callback 'capture failed'

  getProperty: (code, callback = ->) ->
    debug "request getProperty(#{code})"
    @client.getDeviceProperty
      code: code
      onSuccess: (res) ->
        callback null, res
      onFailure: ->
        name = ptp.devicePropCodes[code] or 'undefined'
        callback "getting property \"#{name}\" was failed"

  getPicture: (object_id, callback = ->) ->
    debug "request getPicture(#{object_id})"
    @client.getObject
      objectId: object_id
      onSuccess: (res) ->
        debug "getPicture(#{object_id}) done"
        callback null, new Buffer(res.dataPacket.array)
      onFailure: ->
        debug "getPicture(#{object_id}) failed"
        callback "error"

  listPictures: (callback = ->) ->
    debug "request pictures list"
    @client.getObjectHandles
      args: [0xFFFFFFFF, 0x00000000, 0]
      onSuccess: (res) ->
        arr = res.dataPacket.array.splice(0).splice(8)
        pictures = []
        for i in [0...arr.length/4]
          object_id = 0
          for j in [0...4]
            object_id += (arr[i*4+j] << (8*j))
          pictures.unshift object_id
        debug "list #{pictures.length} pictures"
        callback null, pictures
      onFailure: ->
        callback "error"
