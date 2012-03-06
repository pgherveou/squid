(function() {
  var BuildError, Builder, CoffeeBuilder, cs, fs, logger, _, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  fs = require('fs');

  _ = require('nimble');

  cs = require('coffee-script');

  _ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

  logger = require('./loggers').get('util');

  module.exports = CoffeeBuilder = (function() {

    __extends(CoffeeBuilder, Builder);

    function CoffeeBuilder() {
      CoffeeBuilder.__super__.constructor.apply(this, arguments);
    }

    CoffeeBuilder.prototype.fileExt = ".coffee";

    CoffeeBuilder.prototype.reg = /^#= import (.*)$/gm;

    CoffeeBuilder.prototype._build = function(file, code, refresh, cb) {
      var _this = this;
      if (refresh && this.deps[file].refreshs.length) {
        return _.each(this.deps[file].refreshs, function(f, cb) {
          return _this.build(f, refresh, cb);
        }, function(err) {
          if (err) {
            return cb(new BuildError(file, err));
          } else {
            return cb(null);
          }
        });
      } else {
        return _.map(this.deps[file].imports, function(importFile, cb) {
          return fs.readFile(importFile, 'utf8', cb);
        }, function(err, imports) {
          var js;
          if (err) return cb(new BuildError(file, err));
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

  })();

}).call(this);
