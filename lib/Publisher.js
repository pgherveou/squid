var Publisher, async, crypto, expireDate, fs, knox, logger, mime, moment, path, walk, zlib, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

zlib = require('zlib');

crypto = require('crypto');

knox = require('knox');

mime = require('mime');

async = require('async');

_ = require('underscore');

moment = require('moment');

logger = require('./loggers').get('util');

walk = require('./finder').walk;

expireDate = moment().add('years', 10).format('ddd, DD MMM YYYY') + " 12:00:00 GMT";

module.exports = Publisher = (function() {

  Publisher.name = 'Publisher';

  function Publisher(config) {
    this.publish = __bind(this.publish, this);
    this.client = knox.createClient(config);
  }

  Publisher.prototype.publishDir = function(_arg, cb) {
    var dest, filter, origin,
      _this = this;
    origin = _arg.origin, dest = _arg.dest, filter = _arg.filter;
    filter || (filter = function() {
      return true;
    });
    origin = path.join(path.resolve(origin));
    logger.info("uploading new files from '" + origin + "' to '/" + dest + "'");
    return walk(origin, filter, function(err, fileItems) {
      var file, files, q, stat;
      if (err) {
        return logger.error(err);
      }
      files = (function() {
        var _results;
        _results = [];
        for (file in fileItems) {
          stat = fileItems[file];
          if (stat.isFile()) {
            _results.push(file);
          }
        }
        return _results;
      })();
      q = async.queue(_this.publish, 2);
      q.drain = function() {
        logger.debug("All files were uploaded");
        return cb();
      };
      return files.forEach(function(file) {
        var filename;
        filename = file.replace(origin, dest);
        return q.push({
          file: file,
          filename: filename
        }, function() {});
      });
    });
  };

  Publisher.prototype.publish = function(_arg, cb) {
    var file, filename,
      _this = this;
    file = _arg.file, filename = _arg.filename;
    return async.waterfall([
      function(cb) {
        return fs.readFile(file, cb);
      }, function(buf, cb) {
        if (/\.(css|js)$/.test(file)) {
          return zlib.gzip(buf, function(err, zip) {
            if (err) {
              return cb(new Error("Error zipping " + file));
            }
            return cb(null, zip, {
              'Content-Encoding': 'gzip'
            });
          });
        } else {
          return cb(null, buf, {});
        }
      }, function(buf, headers, cb) {
        _(headers).extend({
          'Expires': expireDate,
          'Content-Type': mime.lookup(file),
          'Content-Length': buf.length
        });
        return _this.client.headFile(filename, function(err, res) {
          var md5, req;
          if (err) {
            return cb(err);
          }
          md5 = '"' + crypto.createHash('md5').update(buf).digest('hex') + '"';
          if (md5 === res.headers.etag) {
            logger.debug("[skip]    " + filename);
            return cb(null);
          } else if (res.headers.etag) {
            logger.debug("[UPDATE]  " + filename);
          } else {
            logger.debug("[ADD]     " + filename);
          }
          req = _this.client.put(filename, headers);
          req.on('response', function(res) {
            return cb(res.statusCode !== 200);
          });
          return req.end(buf);
        });
      }
    ], cb);
  };

  return Publisher;

})();