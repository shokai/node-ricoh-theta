process.env.NODE_ENV = 'test'

path   = require 'path'
assert = require 'assert'

Theta  = require path.resolve()

describe 'instance of Theta', ->

  theta  = new Theta()

  it 'should have method "connect"', ->
    assert.equal typeof theta['connect'], 'function'

  it 'should have method "disconnect"', ->
    assert.equal typeof theta['disconnect'], 'function'

  it 'should have getter "isOpen"', ->
    assert.equal typeof theta.__lookupGetter__('isOpen'), 'function'

  it 'should emit "connect" event', (done) ->
    theta.connect()
    theta.on 'connect', ->
      assert.equal theta.isOpen, true
      done()
    assert.equal theta.isOpen, false

  it 'should have method "capture"', ->
    assert.equal typeof theta['capture'], 'function'

  it 'should have method "getProperty"', ->
    assert.equal typeof theta['getProperty'], 'function'

  describe 'method "getProperty"', ->

    it 'should return property', (done) ->
      theta.getProperty 0x502C, (err, res) ->
        console.error(err) if err
        assert.equal typeof res.dataPacket?.array[0], 'number'
        done()

  it 'should have method "setProperty"', ->
    assert.equal typeof theta['setProperty'], 'function'

  it 'should have method "getPicture"', ->
    assert.equal typeof theta['getPicture'], 'function'

  it 'should have method "getPictureInfo"', ->
    assert.equal typeof theta['getPictureInfo'], 'function'

  it 'should have method "listPictures"', ->
    assert.equal typeof theta['listPictures'], 'function'

  describe 'method "listPictures"', ->

    it 'should return list of pictures', (done) ->
      theta.listPictures (err, object_handles) ->
        console.error err if err
        assert.equal object_handles instanceof Array, true
        done()

  it 'should have method "deletePicture"', ->
    assert.equal typeof theta['deletePicture'], 'function'

  describe 'method "disconnect"', ->

    it 'should close ptp-ip connection', (done) ->
      theta.disconnect()
      theta.once 'disconnect', ->
        assert.equal theta.isOpen, false
        done()
