var BuildError, Builder, StylusBuilder, logger, nib, path, stylus, _, _ref,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

path = require('path');

_ = require('nimble');

stylus = require('stylus');

nib = require('nib');

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

logger = require('./loggers').get('util');

module.exports = StylusBuilder = (function(_super) {

  __extends(StylusBuilder, _super);

  function StylusBuilder() {
    StylusBuilder.__super__.constructor.apply(this, arguments);
  }

  StylusBuilder.prototype.reg = /^@import "(.*)"$/gm;

  StylusBuilder.prototype.fileExt = ".styl";

  StylusBuilder.prototype._build = function(file, code, refresh, cb) {
    var _this = this;
    if (this.deps[file].refreshs.length === 0) {
      return this._compile(file, code, function(err, css) {
        if (err) return cb(new BuildError(file, err));
        return _this.write(css, _this.buildPath(file, '.css'), cb);
      });
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

  StylusBuilder.prototype._compile = function(file, code, cb) {
    return stylus(code).set('fileName', file).set('paths', ['public/images', path.dirname(file)]).use(nib())["import"]('nib').render(cb);
  };

  return StylusBuilder;

})(Builder);
