// Generated by CoffeeScript 1.6.3
var BuildError, Builder, CSSBuilder, CSSLint, path, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

path = require('path');

CSSLint = require('csslint').CSSLint;

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

module.exports = CSSBuilder = (function(_super) {
  __extends(CSSBuilder, _super);

  CSSBuilder.prototype.fileExt = '.css';

  CSSBuilder.prototype.outExt = '.css';

  function CSSBuilder() {
    CSSBuilder.__super__.constructor.apply(this, arguments);
    this.cssConfig = this.config.builders.css;
  }

  CSSBuilder.prototype._build = function(file, code, refresh, cb) {
    var error;
    error = CSSLint.verify(code).messages.filter(function(msg) {
      return msg.type === 'error';
    }).map(function(msg) {
      return "line " + msg.line + ": " + msg.message;
    }).join('\n');
    if (error) {
      return cb(new BuildError(file, error));
    }
    return this.write(code, file, cb);
  };

  return CSSBuilder;

})(Builder);
