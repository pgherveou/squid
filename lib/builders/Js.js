// Generated by CoffeeScript 1.6.2
var BuildError, Builder, JSBuilder, async, fs, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

async = require('async');

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

module.exports = JSBuilder = (function(_super) {
  __extends(JSBuilder, _super);

  function JSBuilder() {
    _ref1 = JSBuilder.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  JSBuilder.prototype.fileExt = '.js';

  JSBuilder.prototype.outExt = '.js';

  JSBuilder.prototype.reg = /^\/\/= import (.*)$/gm;

  JSBuilder.prototype._build = function(file, code, refresh, cb) {
    var _this = this;

    if (refresh && this.deps[file].refreshs.length) {
      return async.forEach(this.deps[file].refreshs, function(f, cb) {
        return _this.build(f, refresh, cb);
      }, function(err) {
        if (err) {
          return cb(new BuildError(file, err));
        } else {
          return cb(null);
        }
      });
    } else {
      return async.map(this.deps[file].imports, function(importFile, cb) {
        return fs.readFile(importFile, 'utf8', cb);
      }, function(err, imports) {
        if (err) {
          return cb(new BuildError(file, err));
        }
        code += imports.join('\n');
        return _this.write(code, file, cb);
      });
    }
  };

  return JSBuilder;

})(Builder);