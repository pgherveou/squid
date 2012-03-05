var BuildError, CSBuilder, JSBuilder, StylusBuilder, builders, fs, getBuilder, path, _;

path = require('path');

fs = require('fs');

BuildError = require('./Builder').BuildError;

CSBuilder = require('./CSBuilder');

JSBuilder = require('./JSBuilder');

StylusBuilder = require('./StylusBuilder');

_ = require('nimble');

builders = {
  '.coffee': new CSBuilder('src', 'lib'),
  '.js': new JSBuilder('src', 'lib'),
  '.styl': new StylusBuilder('src', 'lib')
};

getBuilder = function(file) {
  return builders[path.extname(file)];
};

module.exports = {
  build: function(file, cb) {
    return getBuilder(file).build(file, true, cb);
  },
  buildAll: function(fileItems, cb) {
    var builder, code, file, files, _i, _len;
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
    logger.debug('build all ...');
    return _.reduce(fileItems, function(memo, stat, file, cb) {
      debugger;      builder = getBuilder(file);
      if (!builder) return cb(null, memo);
      return builder.build(file, false, function(err) {
        if (err) memo.push(new BuildError(file, err));
        return cb(null, memo);
      });
    }, [], function(err, errors) {
      if (errors) {
        return cb(errors);
      } else {
        return cb(null);
      }
    });
  }
};
