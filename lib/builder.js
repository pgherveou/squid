(function() {
  var Builder, fs, logger, mkdirp, path, _;

  path = require('path');

  fs = require('fs');

  mkdirp = require('mkdirp');

  _ = require('nimble');

  logger = require('./loggers').get('util');

  exports.BuildError = function(file, error) {
    var _ref, _ref2;
    Error.call(this);
    this.file = file;
    if ((_ref = this.message) == null) {
      this.message = (_ref2 = error.message) != null ? _ref2 : error.message = error;
    }
    return this.name = 'Build Error';
  };

  exports.Builder = Builder = (function() {

    function Builder(srcDir, buildDir) {
      this.srcDir = path.resolve(srcDir);
      this.buildDir = path.resolve(buildDir);
    }

    Builder.prototype.deps = {};

    Builder.prototype.buildPath = function(source, ext) {
      var dir, fileName;
      if (ext == null) ext = '.js';
      fileName = path.basename(source, path.extname(source)) + ext;
      dir = this.buildDir + path.dirname(source).substring(this.srcDir.length);
      return path.join(dir, fileName);
    };

    Builder.prototype.write = function(newCode, file, cb) {
      var _this = this;
      return fs.readFile(file, 'utf8', function(err, oldCode) {
        if (newCode === oldCode) return cb(null, file, "identical " + file);
        return mkdirp(path.dirname(file), 0755, function(err) {
          if (err) return cb(new BuildError(file, err));
          return fs.writeFile(file, newCode, function(err) {
            if (err) return cb(new BuildError(file, err));
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
        _results.push(path.resolve(path.dirname(file), m[1]) + this.fileExt);
      }
      return _results;
    };

    Builder.prototype.scan = function(file, code) {
      var _base, _ref;
      var _this = this;
      if ((_ref = (_base = this.deps)[file]) == null) {
        _base[file] = {
          imports: [],
          refreshs: []
        };
      }
      this.deps[file].imports = [];
      return this.getImports(file, code).forEach(function(importFile) {
        var _base2, _ref2;
        _this.deps[file].imports.push(importFile);
        if ((_ref2 = (_base2 = _this.deps)[importFile]) == null) {
          _base2[importFile] = {
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
        if (err) return cb(new BuildError(file, err));
        _this.scan(file, code);
        return _this._build(file, code, refresh, cb);
      });
    };

    return Builder;

  })();

}).call(this);
