(function() {
  var BuildError, Builder, JadeBuilder, amdWrap, jade, logger, path, _, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  path = require('path');

  _ = require('nimble');

  jade = require('jade');

  _ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

  logger = require('./loggers').get('util');

  amdWrap = function(fn) {
    return "define('jade', function(jade) {\n  return " + (fn.toString()) + ";\n});";
  };

  module.exports = JadeBuilder = (function() {

    __extends(JadeBuilder, Builder);

    function JadeBuilder() {
      JadeBuilder.__super__.constructor.apply(this, arguments);
    }

    JadeBuilder.prototype.reg = /^include "(.*)"$/gm;

    JadeBuilder.prototype.fileExt = ".jade";

    JadeBuilder.prototype._build = function(file, code, refresh, cb) {
      var tplFn;
      var _this = this;
      if (this.deps[file].refreshs.length === 0) {
        try {
          tplFn = jade.compile(code, {
            filename: file,
            client: true,
            compileDebug: false
          });
        } catch (error) {
          return cb(new BuildError(file, error));
        }
        return this.write(amdWrap(tplFn), this.buildPath(file, '.js'), cb);
      } else if (refresh) {
        return _.each(this.deps[file].refreshs, function(f, cb) {
          return _this.build(f, refresh, cb);
        }, function(err) {
          if (err) return cb(new BuildError(file, err));
          return cb(null, file, 'Compilation succeeded');
        });
      } else {
        return cb(null, file, 'nothing to build');
      }
    };

    return JadeBuilder;

  })();

}).call(this);
