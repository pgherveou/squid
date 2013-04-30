// Generated by CoffeeScript 1.6.2
var BuildError, Builder, StylusBuilder, async, nib, os, path, stylus, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

path = require('path');

os = require('os');

async = require('async');

stylus = require('stylus');

nib = require('nib');

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

module.exports = StylusBuilder = (function(_super) {
  __extends(StylusBuilder, _super);

  StylusBuilder.prototype.reg = /^@import "(.*)"$/gm;

  StylusBuilder.prototype.fileExt = '.styl';

  StylusBuilder.prototype.outExt = '.css';

  function StylusBuilder() {
    this._compile = __bind(this._compile, this);    StylusBuilder.__super__.constructor.apply(this, arguments);
    this.stylusConfig = this.config.builders.stylus;
  }

  StylusBuilder.prototype._build = function(file, code, refresh, cb) {
    var _this = this;

    if (this.deps[file].refreshs.length === 0) {
      return this._compile(file, code, function(err, css) {
        if (err) {
          return cb(new BuildError(file, err));
        }
        return _this.write(css, file, cb);
      });
    } else if (refresh) {
      return async.forEach(this.deps[file].refreshs, function(f, cb) {
        return _this.build(f, refresh, cb);
      }, function(err) {
        if (err) {
          return cb(new BuildError(file, err));
        }
        return cb(null, file, 'Compilation succeeded');
      });
    } else {
      return cb(null, file, 'nothing to build');
    }
  };

  StylusBuilder.prototype._compile = function(file, code, cb) {
    var compiler, i, _i, _len, _ref1;

    compiler = stylus(code).set('fileName', file).set('compress', true).define('env', process.env.NODE_ENV || 'development').define('host', os.hostname()).set('paths', this.stylusConfig.paths.concat(path.dirname(file)));
    if (this.stylusConfig.url) {
      compiler.define('url', stylus.url(this.stylusConfig.url));
    }
    if (this.stylusConfig.nib) {
      compiler.use(nib())["import"]('nib');
    }
    if (this.stylusConfig.imports) {
      _ref1 = this.stylusConfig.imports;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        i = _ref1[_i];
        compiler.use(nib())["import"](i);
      }
    }
    return compiler.render(cb);
  };

  return StylusBuilder;

})(Builder);