var BuildError, Builder, CoffeeBuilder, async, cs, fs, logger, path, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

async = require('async');

cs = require('coffee-script');

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

logger = require('./loggers').get('util');

module.exports = CoffeeBuilder = (function(_super) {

  __extends(CoffeeBuilder, _super);

  CoffeeBuilder.name = 'CoffeeBuilder';

  function CoffeeBuilder() {
    return CoffeeBuilder.__super__.constructor.apply(this, arguments);
  }

  CoffeeBuilder.prototype.fileExt = ".coffee";

  CoffeeBuilder.prototype.reg = /^#= import (.*)$/gm;

  CoffeeBuilder.prototype._build = function(file, code, refresh, cb) {
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
        return fs.readFile(importFile, 'utf8', function(err, data) {
          if (err) {
            return cb(err);
          }
          if (path.extname(importFile) === '.coffee') {
            return cb(null, data);
          }
          if (path.extname(importFile) === '.js') {
            return cb(null, "`" + data + "`");
          }
          return cb(new BuildError(importFile, 'file extension not supported'));
        });
      }, function(err, imports) {
        var js;
        if (err) {
          return cb(new BuildError(file, err));
        }
        code = imports.join('\n') + code;
        try {
          js = cs.compile(code, {
            bare: true
          });
          return _this.write(js, _this.buildPath(file), cb);
        } catch (err) {
          return cb(new BuildError(file, err));
        }
      });
    }
  };

  return CoffeeBuilder;

})(Builder);
