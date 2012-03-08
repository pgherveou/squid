var events, fs, path, q, walk, watch, _,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

events = require('events');

_ = require('underscore');

q = require('sink').q;

exports.walk = walk = function(dir, filter, fn) {
  var traverse;
  dir = path.resolve(dir);
  if (arguments.length === 2) {
    fn = filter;
    filter = null;
  }
  if (fn.files == null) fn.files = {};
  q(fs.stat, dir, function(err, stat) {
    if (err) fn(err);
    return fn.files[dir] = stat;
  });
  traverse = function(dir) {
    return q(fs.readdir, dir, function(err, files) {
      if (err) fn(err);
      return _(files).each(function(filename) {
        var file;
        file = path.join(dir, filename);
        return q(fs.stat, file, function(err, stat) {
          if (err) return fn(err);
          if (!(filter && filter(filename, stat))) return;
          fn.files[file] = stat;
          if (stat.isDirectory()) return traverse(file);
        });
      });
    });
  };
  traverse(dir);
  return q(function() {
    return fn(null, fn.files);
  });
};

exports.watch = watch = function(dir, filter, fn) {
  return walk(dir, filter, function(err, files) {
    var file, watcher;
    if (err) return console.error(err);
    watcher = function(f) {
      return fs.watchFile(f, {
        interval: 50,
        persistent: true
      }, function(curr, prev) {
        if (files[f] && files[f].isFile() && curr.nlink !== 0 && curr.mtime.getTime() === prev.mtime.getTime()) {
          return;
        }
        files[f] = curr;
        if (files[f].isFile()) {
          fn(f, curr, prev);
        } else if (curr.nlink !== 0) {
          fs.readdir(f, function(err, dirFiles) {
            if (err) return console.error("err loading " + f + " : " + err);
            return _(dirFiles).each(function(filename) {
              var file;
              file = path.join(f, filename);
              if (!files[file]) {
                return fs.stat(file, function(err, stat) {
                  if (err) {
                    return console.error("err loading " + file + " : " + err);
                  }
                  if (filter(file, stat)) {
                    fn(file, stat, null);
                    files[file] = stat;
                    return watcher(file);
                  }
                });
              }
            });
          });
        }
        if (curr.nlink === 0) {
          delete files[f];
          return fs.unwatchFile(f);
        }
      });
    };
    for (file in files) {
      watcher(file);
    }
    return fn(files, null, null);
  });
};

exports.Monitor = (function(_super) {

  __extends(Monitor, _super);

  function Monitor(name, dir, filter) {
    this.name = name;
    this.dir = dir;
    this.filter = filter;
    this.state = 'stopped';
    this.files = {};
  }

  Monitor.prototype.start = function() {
    var _this = this;
    if (this.state !== 'stopped') return;
    this.state = 'running';
    return watch(this.dir, this.filter, function(f, curr, prev) {
      if (curr === null && prev === null) {
        _(_this.files).extend(f);
        return _this.emit('started', _this.files);
      } else if (prev === null) {
        return _this.emit('created', f, curr, prev);
      } else if (curr.nlink === 0) {
        return _this.emit('removed', f, curr, prev);
      } else {
        return _this.emit('changed', f, curr, prev);
      }
    });
  };

  Monitor.prototype.stop = function() {
    var file;
    if (this.state !== 'running') return;
    this.state = 'stopped';
    for (file in this.files) {
      fs.unwatchFile(file);
    }
    return this.emit('stopped');
  };

  return Monitor;

})(events.EventEmitter);
