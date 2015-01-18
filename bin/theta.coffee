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
]

parser.on 'help', ->
  package_json = require "#{__dirname}/../package.json"
  parser.banner = """
  linda-server v#{package_json.version} - #{package_json.homepage}

  Usage:
    % theta --capture
    % theta --capture out.jpg
    % DEBUG=* theta capture
  """
  console.log parser.toString()
  process.exit 0

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
    theta.getPicture object_id, (err, picture) ->
      if err
        console.error err
        return process.exit 1
      fs.writeFile filename, picture, (err) ->
        console.log "picture saved => #{filename}"
        theta.disconnect()

parser.parse process.argv
