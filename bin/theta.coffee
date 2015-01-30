#!/usr/bin/env coffee

fs   = require 'fs'
path = require 'path'

optparse = require 'optparse'

Theta = require path.resolve("#{__dirname}/../")
theta = new Theta

config = {}

parser = new optparse.OptionParser [
  ['-h', '--help', 'show help']
  ['--capture [FILENAME]', 'take a picture']
  ['--list', 'list pictures']
  ['--handle [Object Handle]', 'specify picture by Object Handle']
  ['--save [FILENAME]', 'save picture']
  ['--delete [Object Handle]', 'delete a picture']
  ['--info [Object Handle]', 'show picture info']
  ['--battery', 'check battery level']
  ['--volume [NUMBER]', 'get/set audio volume (0~100)']
]

parser.filter 'NUMBER', (v) ->
  return v unless v # allow empty argument
  if /^[1-9][0-9]*(\.\d+)?$/.test v
    return v - 0
  throw "invalid number - \"#{v}\""

parser.on 'help', ->
  package_json = require "#{__dirname}/../package.json"
  parser.banner = """
  theta v#{package_json.version} - #{package_json.homepage}

  Usage:
    % theta --capture
    % theta --capture out.jpg
    % theta --list
    % theta --handle [object_handle] --save out.jpg
    % theta --delete [object_handle]
    % theta --info   [object_handle]
    % theta --battery
    % theta --volume           # get audio volume
    % theta --volume 20        # set audio volume
    % DEBUG=* theta --capture  # print all debug messages
  """
  console.log parser.toString()
  return process.exit 0

savePicture = (object_handle, filename) ->
  theta.getPicture object_handle, (err, picture) ->
    if err
      console.error err
      return process.exit 1
    fs.writeFile filename, picture, (err) ->
      console.log "picture (Handle:#{object_handle}) saved => #{filename}"
      theta.disconnect()

parser.on 'capture', (opt, filename) ->
  theta.connect()
  theta.once 'connect', ->
    theta.capture (err) ->
      if err
        console.error err
        return process.exit 1
      console.log 'capture success'
      unless filename
        return theta.disconnect()

  theta.once 'objectAdded', (object_handle) ->
    savePicture object_handle, filename

parser.on 'list', ->
  theta.connect()
  theta.once 'connect', ->
    theta.listPictures (err, object_handles) ->
      console.log "Object Handles: #{JSON.stringify(object_handles)}"
      console.log "#{object_handles.length} pictures"
      theta.disconnect()

parser.on 'handle', (opt, object_handle) ->
  config.object_handle = object_handle

parser.on 'save', (opt, filename) ->
  unless typeof config.object_handle is 'string'
    console.error '"--handle=[object_handle]" option required'
    return process.exit 1
  theta.connect()
  theta.once 'connect', ->
    savePicture config.object_handle, filename

parser.on 'delete', (opt, object_handle) ->
  theta.connect()
  theta.once 'connect', ->
    theta.deletePicture object_handle, (err) ->
      if err
        console.error err
        return process.exit 1
      console.log "delete #{object_handle} success"
      theta.disconnect()

parser.on 'info', (opt, object_handle) ->
  theta.connect()
  theta.once 'connect', ->
    theta.getPictureInfo object_handle, (err, info) ->
      if err
        console.error err
        return process.exit 1
      console.log info
      theta.disconnect()

parser.on 'battery', ->
  theta.connect()
  theta.once 'connect', ->
    theta.getBatteryLevel (err, res) ->
      if err
        console.error err
        return process.exit 1
      console.log "BatteryLevel: #{res.dataPacket.array[0]}"
      theta.disconnect()


parser.on 'volume', (opt, volume) ->
  theta.connect()
  theta.once 'connect', ->
    unless volume
      theta.getProperty 0x502C, (err, res) ->
        if err
          console.error err
          return process.exit 1
        console.log "AudioVolume: #{res.dataPacket.array[0]}"
        theta.disconnect()
      return
    theta.setProperty 0x502C, volume, (err, res) ->
      if err
        console.error err
        return process.exit 1
      theta.getProperty 0x502C, (err, res) ->
        if err
          console.error err
          return process.exit 1
        console.log "AudioVolume: #{res.dataPacket.array[0]}"
        theta.disconnect()

if process.argv.length < 3
  parser.on_switches.help.call()

parser.parse process.argv
