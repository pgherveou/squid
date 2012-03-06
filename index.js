var fs = require('fs')
  , util = require('util');


module.exports.loggers = require('./lib/loggers');
module.exports.builder = require('./lib/projectBuilder');

module.exports.copy = function(src, dest, cb) {
  var destFile, srcFile;
  srcFile = fs.createReadStream(src);
  destFile = fs.createWriteStream(dest);
  return srcFile.once('open', function() {
    return util.pump(srcFile, destFile, cb);
  });
};
