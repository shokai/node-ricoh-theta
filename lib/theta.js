(function() {
  'use strict';
  var Theta, debug, events, ptp,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  debug = require('debug')('ricoh-theta');

  events = require('events');

  ptp = require('ptp');

  module.exports = Theta = (function(_super) {
    __extends(Theta, _super);

    function Theta() {
      var code, name, _fn, _ref;
      this.client = ptp;
      this.client.onConnected = (function(_this) {
        return function() {
          debug('ptp connect');
          return _this.emit('connect');
        };
      })(this);
      this.client.onDisconnected = (function(_this) {
        return function() {
          debug('ptp disconnect');
          return _this.emit('disconnect');
        };
      })(this);
      this.client.onError = (function(_this) {
        return function(err) {
          debug("ptp error - " + err);
          return _this.emit('error');
        };
      })(this);
      _ref = ptp.devicePropCodes;
      _fn = (function(_this) {
        return function(name, code) {
          var method_name;
          method_name = "get" + (name[0].toUpperCase()) + name.slice(1);
          return _this[method_name] = function(callback) {
            if (callback == null) {
              callback = function() {};
            }
            debug("get property \"" + method_name + "\" - code: " + code);
            return _this.getProperty(code, callback);
          };
        };
      })(this);
      for (name in _ref) {
        code = _ref[name];
        _fn(name, code);
      }
    }

    Theta.prototype.connect = function(host) {
      this.host = host != null ? host : '192.168.1.1';
      this.client.host = this.host;
      this.client.clientName = 'ricoh-theta npm';
      debug('connecting..');
      this.client.connect();
      this.client.onObjectAdded = (function(_this) {
        return function(res) {
          var object_id, _ref;
          object_id = (_ref = res.parameters) != null ? _ref[1] : void 0;
          debug("objectAdded: " + object_id);
          return _this.emit('objectAdded', object_id);
        };
      })(this);
      return this;
    };

    Theta.prototype.disconnect = function() {
      return this.client.disconnect();
    };

    Theta.prototype.capture = function(callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request capture");
      return this.client.capture({
        onSuccess: function() {
          return callback(null);
        },
        onFailure: function() {
          return callback('capture failed');
        }
      });
    };

    Theta.prototype.getProperty = function(code, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request getProperty(" + code + ")");
      return this.client.getDeviceProperty({
        code: code,
        onSuccess: function(res) {
          return callback(null, res);
        },
        onFailure: function() {
          var name;
          name = ptp.devicePropCodes[code] || 'undefined';
          return callback("getting property \"" + name + "\" was failed");
        }
      });
    };

    Theta.prototype.getPicture = function(object_id, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request getPicture(" + object_id + ")");
      return this.client.getObject({
        objectId: object_id,
        onSuccess: function(res) {
          debug("getPicture(" + object_id + ") done");
          return callback(null, new Buffer(res.dataPacket.array));
        },
        onFailure: function() {
          debug("getPicture(" + object_id + ") failed");
          return callback("error");
        }
      });
    };

    Theta.prototype.listPictures = function(callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request pictures list");
      return this.client.getObjectHandles({
        args: [0xFFFFFFFF, 0x00000000, 0],
        onSuccess: function(res) {
          var arr, i, j, object_id, pictures, _i, _j, _ref;
          arr = res.dataPacket.array.splice(0).splice(8);
          pictures = [];
          for (i = _i = 0, _ref = arr.length / 4; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            object_id = 0;
            for (j = _j = 0; _j < 4; j = ++_j) {
              object_id += arr[i * 4 + j] << (8 * j);
            }
            pictures.unshift(object_id);
          }
          debug("list " + pictures.length + " pictures");
          return callback(null, pictures);
        },
        onFailure: function() {
          return callback("error");
        }
      });
    };

    return Theta;

  })(events.EventEmitter);

}).call(this);
