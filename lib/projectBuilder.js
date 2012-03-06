(function() {
  var CSBuilder, JSBuilder, StylusBuilder, buildFactory, fs, logger, path, walk, _;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  path = require('path');

  fs = require('fs');

  _ = require('nimble');

  walk = require('./finder').walk;

  CSBuilder = require('./CSBuilder');

  JSBuilder = require('./JSBuilder');

  StylusBuilder = require('./StylusBuilder');

  logger = require('./loggers').get('util');

  buildFactory = {
    get: function(file) {
      return this[path.extname(file)];
    },
    '.coffee': new CSBuilder('src', '.'),
    '.js': new JSBuilder('src', '.'),
    '.styl': new StylusBuilder('src', '.')
  };

  module.exports = {
    buildAll: function(exceptFolders, cb) {
      var filter;
      var _this = this;
      if (exceptFolders == null) exceptFolders = [];
      cb || (cb = function(errors) {
        var e, _i, _len, _results;
        if (errors) {
          _results = [];
          for (_i = 0, _len = errors.length; _i < _len; _i++) {
            e = errors[_i];
            _results.push(logger.error("file: " + e.file + " :\n e.message"));
          }
          return _results;
        } else {
          return logger.info("Build done.");
        }
      });
      filter = function(f, stat) {
        var _ref;
        if (stat.isDirectory() && (_ref = path.basename(f), __indexOf.call(exceptFolders, _ref) >= 0)) {
          return false;
        }
        if (stat.isDirectory()) return true;
        return /\.(coffee|js|styl)$/.test(f);
      };
      return walk("src", filter, function(err, files) {
        if (err) return logger.error(err);
        return _this.liveBuildAll(files, cb);
      });
    },
    removeBuild: function(file, cb) {
      return buildFactory.get(file).removeBuild(file, cb);
    },
    liveBuild: function(file, cb) {
      return buildFactory.get(file).build(file, true, cb);
    },
    liveBuildAll: function(fileItems, cb) {
      var buildFile, builder, code, errors, file, files, _i, _len;
      files = (function() {
        var _results;
        _results = [];
        for (file in fileItems) {
          _results.push(file);
        }
        return _results;
      })();
      logger.debug('scan all ...');
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        if (builder = buildFactory.get(file)) {
          code = fs.readFileSync(file, 'utf8');
          builder.scan(file, code);
        }
      }
      errors = [];
      buildFile = function(file, cb) {
        builder = buildFactory.get(file);
        if (!builder) return cb(null);
        return builder.build(file, false, function(err) {
          if (err) errors.push(err);
          return cb(null);
        });
      };
      return _.each(files, buildFile, function() {
        if (errors.length) {
          return cb(errors);
        } else {
          return cb(null);
        }
      });
    }
  };

}).call(this);
