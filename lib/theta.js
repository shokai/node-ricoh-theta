(function() {
  'use strict';
  var Theta, debug, events,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  debug = require('debug')('ricoh-theta');

  events = require('events');

  module.exports = Theta = (function(_super) {
    __extends(Theta, _super);

    function Theta() {
      this.client = require('ptp');
      this.client.onDisconnected = (function(_this) {
        return function() {
          debug('ptp disconnect');
          return _this.emit('disconnect');
        };
      })(this);
      this.client.onConnected = (function(_this) {
        return function() {
          debug('ptp connect');
          return _this.emit('connect');
        };
      })(this);
      this.client.onError = (function(_this) {
        return function(err) {
          debug("ptp error - " + err);
          return _this.emit('error');
        };
      })(this);
    }

    Theta.prototype.connect = function(host) {
      this.host = host != null ? host : '192.168.1.1';
      this.client.host = this.host;
      this.client.clientName = 'ricoh-theta npm';
      debug('connecting..');
      this.client.connect();
      return this;
    };

    Theta.prototype.capture = function(callback) {
      if (callback == null) {
        callback = function() {};
      }
      return this.client.capture({
        onSuccess: function() {
          return callback();
        },
        onFailure: function() {
          return callback('capture failed');
        }
      });
    };

    Theta.prototype.list = function() {};

    return Theta;

  })(events.EventEmitter);

}).call(this);
