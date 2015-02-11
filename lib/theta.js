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
      var code, isOpen, name, _fn, _ref;
      this.client = ptp;
      isOpen = false;
      this.__defineGetter__('isOpen', function() {
        return isOpen;
      });
      this.client.onConnected = (function(_this) {
        return function() {
          debug('ptp connect');
          isOpen = true;
          return _this.emit('connect');
        };
      })(this);
      this.client.onDisconnected = (function(_this) {
        return function() {
          debug('ptp disconnect');
          isOpen = false;
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
          var object_handle, _ref;
          object_handle = (_ref = res.parameters) != null ? _ref[1] : void 0;
          debug("objectAdded: " + object_handle);
          return _this.emit('objectAdded', object_handle);
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
        onFailure: function(err) {
          return callback(err || 'capture failed');
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
        onFailure: function(err) {
          var name;
          name = ptp.devicePropCodes[code] || ("code:" + code);
          return callback(err || ("getting property \"" + name + "\" was failed"));
        }
      });
    };

    Theta.prototype.setProperty = function(code, data, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request setProperty(" + code + ")");
      return this.client.setDeviceProperty({
        code: code,
        data: ptp.dataFactory.createDword(data),
        onSuccess: function(res) {
          return callback(null, res);
        },
        onFailure: function(err) {
          var name;
          name = ptp.devicePropCodes[code] || ("code:" + code);
          return callback(err || ("setting property \"" + name + "\" was failed"));
        }
      });
    };

    Theta.prototype.getPicture = function(object_handle, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request getPicture(" + object_handle + ")");
      return this.client.getObject({
        objectHandle: object_handle,
        onSuccess: function(res) {
          debug("getPicture(" + object_handle + ") done");
          return callback(null, new Buffer(res.dataPacket.array));
        },
        onFailure: function(err) {
          debug("getPicture(" + object_handle + ") failed");
          return callback(err || ("getPicture(" + object_handle + ") failed"));
        }
      });
    };

    Theta.prototype.getPictureInfo = function(object_handle, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request getPictureInfo(" + object_handle + ")");
      return this.client.getObjectInfo({
        objectHandle: object_handle,
        onSuccess: function(res) {
          debug("getPictureInfo(" + object_handle + ") done");
          return callback(null, res.objectInfo);
        },
        onFailure: function(err) {
          debug("getPictureInfo(" + object_handle + ") failed");
          return callback(err || ("getPictureInfo(" + object_handle + ") failed"));
        }
      });
    };

    Theta.prototype.listPictures = function(callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request pictures list");
      return this.client.getObjectHandles({
        storageId: 0xFFFFFFFF,
        objectFormatCode: 0x00000000,
        objectHandleOfAssociation: 0,
        onSuccess: function(res) {
          res.handles.shift();
          debug("list " + res.handles.length + " pictures");
          return callback(null, res.handles);
        },
        onFailure: function(err) {
          debug("list pictures failed");
          return callback(err || "list pictures failed");
        }
      });
    };

    Theta.prototype.deletePicture = function(object_handle, callback) {
      if (callback == null) {
        callback = function() {};
      }
      debug("request deletePicture(" + object_handle + ")");
      return this.client.deleteObject({
        objectHandle: object_handle,
        onSuccess: function(res) {
          debug("deletePicture(" + object_handle + ") done");
          return callback(null);
        },
        onFailure: function(err) {
          debug("deletePicture(" + object_handle + ") failed");
          return callback(err || ("deletePicture(" + object_handle + ") failed"));
        }
      });
    };

    return Theta;

  })(events.EventEmitter);

}).call(this);
