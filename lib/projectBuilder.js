(function() {
  var CSBuilder, JSBuilder, StylusBuilder, builders, fs, getBuilder, path, _;

  path = require('path');

  fs = require('fs');

  CSBuilder = require('./CSBuilder');

  JSBuilder = require('./JSBuilder');

  StylusBuilder = require('./StylusBuilder');

  _ = require('nimble');

  builders = {
    '.coffee': new CSBuilder('src', '.'),
    '.js': new JSBuilder('src', '.'),
    '.styl': new StylusBuilder('src', '.')
  };

  getBuilder = function(file) {
    return builders[path.extname(file)];
  };

  module.exports = {
    build: function(file, cb) {
      return getBuilder(file).build(file, true, cb);
    },
    buildAll: function(fileItems, cb) {
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
        if (builder = getBuilder(file)) {
          code = fs.readFileSync(file, 'utf8');
          builder.scan(file, code);
        }
      }
      errors = [];
      buildFile = function(file, cb) {
        builder = getBuilder(file);
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
