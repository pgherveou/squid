(function() {
  var BuildError, Builder, JSBuilder, _, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _ = require('nimble');

  _ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

  module.exports = JSBuilder = (function() {

    __extends(JSBuilder, Builder);

    function JSBuilder() {
      JSBuilder.__super__.constructor.apply(this, arguments);
    }

    JSBuilder.prototype.fileExt = ".js";

    JSBuilder.prototype.reg = /^\/\/= import (.*)$/gm;

    JSBuilder.prototype._build = function(file, code, refresh, cb) {
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
          if (err) return cb(new BuildError(file, err));
          code += imports.join('\n');
          return _this.write(code, _this.buildPath(file), cb);
        });
      }
    };

    return JSBuilder;

  })();

}).call(this);
