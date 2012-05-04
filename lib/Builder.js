var BuildError, Builder, fs, logger, mkdirp, path, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

path = require('path');

fs = require('fs');

mkdirp = require('mkdirp');

_ = require('async');

logger = require('./loggers').get('util');

exports.BuildError = BuildError = (function(_super) {

  __extends(BuildError, _super);

  BuildError.name = 'BuildError';

  BuildError.prototype.name = 'Build Error';

  function BuildError(file, error) {
    this.file = file;
    this.error = error;
  }

  BuildError.prototype.toString = function() {
    return "Build Error on " + this.file + "\n\n" + (this.error.toString()) + "\n\n--\n";
  };

  return BuildError;

})(Error);

exports.Builder = Builder = (function() {

  Builder.name = 'Builder';

  function Builder(srcDir, buildDir) {
    this.srcDir = path.resolve(srcDir);
    this.buildDir = path.resolve(buildDir);
  }

  Builder.prototype.deps = {};

  Builder.prototype.buildPath = function(source, ext) {
    var dir, fileName;
    if (ext == null) {
      ext = '.js';
    }
    fileName = path.basename(source, path.extname(source)) + ext;
    dir = this.buildDir + path.dirname(source).substring(this.srcDir.length);
    return path.join(dir, fileName);
  };

  Builder.prototype.write = function(newCode, file, cb) {
    var _this = this;
    return fs.readFile(file, 'utf8', function(err, oldCode) {
      if (newCode === oldCode) {
        return cb(null, file, "identical " + file);
      }
      return mkdirp(path.dirname(file), 0x1ed, function(err) {
        if (err) {
          return cb(new BuildError(file, err));
        }
        return fs.writeFile(file, newCode, function(err) {
          if (err) {
            return cb(new BuildError(file, err));
          }
          cb(null, file, "Compilation succeeded");
          return _this.refreshScan(file, oldCode, newCode);
        });
      });
    });
  };

  Builder.prototype.removeBuild = function(source, cb) {
    return fs.unlink(this.buildPath(source), function(err) {
      return cb(err, source, "");
    });
  };

  Builder.prototype.getImports = function(file, code) {
    var m, _results;
    _results = [];
    while (m = this.reg.exec(code)) {
      _results.push(path.resolve(path.dirname(file), m[1]) + (path.extname(m[1]) ? '' : this.fileExt));
    }
    return _results;
  };

  Builder.prototype.scan = function(file, code) {
    var _base,
      _this = this;
    if ((_base = this.deps)[file] == null) {
      _base[file] = {
        imports: [],
        refreshs: []
      };
    }
    this.deps[file].imports = [];
    return this.getImports(file, code).forEach(function(importFile) {
      var _base1;
      _this.deps[file].imports.push(importFile);
      if ((_base1 = _this.deps)[importFile] == null) {
        _base1[importFile] = {
          imports: [],
          refreshs: []
        };
      }
      if (!~_this.deps[importFile].refreshs.indexOf(file)) {
        return _this.deps[importFile].refreshs.push(file);
      }
    });
  };

  Builder.prototype.refreshScan = function(file, oldCode, newCode) {
    var _this = this;
    this.getImports(file, oldCode).forEach(function(importFile) {
      var refreshs;
      refreshs = _this.deps[importFile].refreshs;
      return delete refreshs[refreshs[indexOf(file)]];
    });
    return this.scan(file, newCode);
  };

  Builder.prototype.build = function(file, refresh, cb) {
    var _this = this;
    return fs.readFile(file, 'utf8', function(err, code) {
      if (err) {
        return cb(new BuildError(file, err));
      }
      _this.scan(file, code);
      return _this._build(file, code, refresh, cb);
    });
  };

  return Builder;

})();