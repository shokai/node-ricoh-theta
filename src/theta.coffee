'use strict'

debug  = require('debug')('ricoh-theta')
events = require 'events'
ptp    = require 'ptp'

module.exports = class Theta extends events.EventEmitter

  constructor: ->
    @client = ptp
    isOpen = false
    @__defineGetter__ 'isOpen', -> isOpen

    @client.onConnected = =>
      debug 'ptp connect'
      isOpen = true
      @emit 'connect'

    @client.onDisconnected = =>
      debug 'ptp disconnect'
      isOpen = false
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
      object_handle = res.parameters?[1]
      debug "objectAdded: #{object_handle}"
      @emit 'objectAdded', object_handle
    return @

  disconnect: ->
    @client.disconnect()

  capture: (callback = ->) ->
    debug "request capture"
    @client.capture
      onSuccess: ->
        callback null
      onFailure: (err) ->
        callback err or 'capture failed'

  getProperty: (code, callback = ->) ->
    debug "request getProperty(#{code})"
    @client.getDeviceProperty
      code: code
      onSuccess: (res) ->
        callback null, res
      onFailure: (err) ->
        name = ptp.devicePropCodes[code] or "code:#{code}"
        callback err or "getting property \"#{name}\" was failed"

  setProperty: (code, data, callback = ->) ->
    debug "request setProperty(#{code})"
    @client.setDeviceProperty
      code: code
      data: ptp.dataFactory.createDword data
      onSuccess: (res) ->
        callback null, res
      onFailure: (err) ->
        name = ptp.devicePropCodes[code] or "code:#{code}"
        callback err or "setting property \"#{name}\" was failed"

  getPicture: (object_handle, callback = ->) ->
    debug "request getPicture(#{object_handle})"
    @client.getObject
      objectHandle: object_handle
      onSuccess: (res) ->
        debug "getPicture(#{object_handle}) done"
        callback null, new Buffer(res.dataPacket.array)
      onFailure: (err) ->
        debug "getPicture(#{object_handle}) failed"
        callback err or "getPicture(#{object_handle}) failed"

  getPictureInfo: (object_handle, callback = ->) ->
    debug "request getPictureInfo(#{object_handle})"
    @client.getObjectInfo
      objectHandle: object_handle
      onSuccess: (res) ->
        debug "getPictureInfo(#{object_handle}) done"
        callback null, res.objectInfo
      onFailure: (err) ->
        debug "getPictureInfo(#{object_handle}) failed"
        callback err or "getPictureInfo(#{object_handle}) failed"

  listPictures: (callback = ->) ->
    debug "request pictures list"
    @client.getObjectHandles
      storageId: 0xFFFFFFFF
      objectFormatCode: 0x00000000
      objectHandleOfAssociation: 0
      onSuccess: (res) ->
        res.handles.shift()
        debug "list #{res.handles.length} pictures"
        callback null, res.handles
      onFailure: (err) ->
        debug "list pictures failed"
        callback err or "list pictures failed"

  deletePicture: (object_handle, callback = ->) ->
    debug "request deletePicture(#{object_handle})"
    @client.deleteObject
      objectHandle: object_handle
      onSuccess: (res) ->
        debug "deletePicture(#{object_handle}) done"
        callback null
      onFailure: (err) ->
        debug "deletePicture(#{object_handle}) failed"
        callback err or "deletePicture(#{object_handle}) failed"
