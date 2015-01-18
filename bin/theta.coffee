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
  ['--id [Object ID]', 'specify picture by ID']
  ['--save [FILENAME]', 'save picture']
]

parser.on 'help', ->
  package_json = require "#{__dirname}/../package.json"
  parser.banner = """
  linda-server v#{package_json.version} - #{package_json.homepage}

  Usage:
    % theta --capture
    % theta --capture out.jpg
    % theta --list
    % theta --id [object_id] --save out.jpg
    % DEBUG=* theta --capture
  """
  console.log parser.toString()
  process.exit 0

savePicture = (object_id, filename) ->
  theta.getPicture object_id, (err, picture) ->
    if err
      console.error err
      return process.exit 1
    fs.writeFile filename, picture, (err) ->
      console.log "picture (ID:#{object_id}) saved => #{filename}"
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

  theta.once 'objectAdded', (object_id) ->
    savePicture object_id, filename

parser.on 'list', ->
  theta.connect()
  theta.once 'connect', ->
    theta.listPictures (err, object_ids) ->
      console.log "Object IDs: #{JSON.stringify(object_ids)}"
      console.log "#{object_ids.length} pictures"
      theta.disconnect()

parser.on 'id', (opt, object_id) ->
  config.object_id = object_id

parser.on 'save', (opt, filename) ->
  theta.connect()
  theta.once 'connect', ->
    savePicture config.object_id, filename

parser.parse process.argv
