Theta = require __dirname+'/../'

theta = new Theta()
theta.connect '192.168.1.1'

theta.on 'connect', ->
  console.log 'connect!!'
  theta.capture (err) ->
    return console.log err if err
    console.log 'captured'
