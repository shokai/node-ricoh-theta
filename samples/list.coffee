Theta = require __dirname+'/../'
theta = new Theta()

theta.on 'connect', ->
  console.log 'connect!!'
  theta.capture (err) ->
    return console.log err if err
    console.log 'captured'
