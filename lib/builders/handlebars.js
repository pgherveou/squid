// Generated by CoffeeScript 1.6.3
var BuildError, Builder, HandleBarsBuilder, handlebars, path, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

path = require('path');

handlebars = require('handlebars');

_ref = require('./Builder'), Builder = _ref.Builder, BuildError = _ref.BuildError;

module.exports = HandleBarsBuilder = (function(_super) {
  var amdWrap, commonJSWrap;

  __extends(HandleBarsBuilder, _super);

  HandleBarsBuilder.prototype.fileExt = '.hbs';

  HandleBarsBuilder.prototype.outExt = '.js';

  commonJSWrap = function(fn) {
    return "var Handlebars = require('handlebars');\nmodule.exports = Handlebars.template(" + fn + ");";
  };

  amdWrap = function(fn) {
    return "define(['handlebars'], function(Handlebars) {\n  return Handlebars.template(" + fn + ");\n});";
  };

  function HandleBarsBuilder() {
    HandleBarsBuilder.__super__.constructor.apply(this, arguments);
    this.hbsConfig = this.config.builders.handlebars;
  }

  HandleBarsBuilder.prototype._build = function(file, code, refresh, cb) {
    var error, tplFn;
    try {
      tplFn = handlebars.precompile(code).toString();
      switch (this.hbsConfig.wrap) {
        case 'amd':
          tplFn = amdWrap(tplFn);
          break;
        case 'commonJS':
          tplFn = commonJSWrap(tplFn);
      }
      return this.write(tplFn, file, cb);
    } catch (_error) {
      error = _error;
      return cb(new BuildError(file, error));
    }
  };

  return HandleBarsBuilder;

})(Builder);
