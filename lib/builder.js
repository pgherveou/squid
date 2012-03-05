(function() {
  var BuildError, Builder, CoffeeBuilder, JSBuilder, StylusBuilder, builders, cs, fs, mkdirp, nib, path, stylus, _;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  path = require('path');

  fs = require('fs');

  cs = require('coffee-script');

  stylus = require('stylus');

  mkdirp = require('mkdirp');

  _ = require('nimble');

  nib = require('nib');

  BuildError = function(file, error) {
    var _ref, _ref2;
    Error.call(this);
    this.file = file;
    if ((_ref = this.message) == null) {
      this.message = (_ref2 = error.message) != null ? _ref2 : error.message = error;
    }
    return this.name = 'Build Error';
  };

  Builder = (function() {

    function Builder() {}

    Builder.prototype.deps = {};

    Builder.prototype.buildPath = function(source, ext) {
      var dir, fileName;
      if (ext == null) ext = '.js';
      fileName = path.basename(source, path.extname(source)) + ext;
      dir = SQ.dir.build + path.dirname(source).substring(SQ.dir.src.length);
      return path.join(dir, fileName);
    };

    Builder.prototype.write = function(newCode, file, cb) {
      var _this = this;
      return fs.readFile(file, 'utf8', function(err, oldCode) {
        if (newCode === oldCode) return cb(null, file, "identical");
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

  /*
  coffee file builder
  */

  CoffeeBuilder = (function() {

    __extends(CoffeeBuilder, Builder);

    function CoffeeBuilder() {
      CoffeeBuilder.__super__.constructor.apply(this, arguments);
    }

    CoffeeBuilder.prototype.fileExt = ".coffee";

    CoffeeBuilder.prototype.reg = /^#= import (.*)$/gm;

    CoffeeBuilder.prototype._build = function(file, code, refresh, cb) {
      var _this = this;
      if (refresh && this.deps[file].refreshs.length) {
        return _.each(this.deps[file].refreshs, function(f, cb) {
          return _this.build(f, refresh, cb);
        }, function(err) {
          if (err) {
            return cb(new BuildError(file, err));
          } else {
            return cb(null);
          }
        });
      } else {
        return _.map(this.deps[file].imports, function(importFile, cb) {
          return fs.readFile(importFile, 'utf8', cb);
        }, function(err, imports) {
          var js;
          if (err) return cb(new BuildError(file, err));
          code = imports.join('\n') + code;
          try {
            js = cs.compile(code, {
              bare: true
            });
            return _this.write(js, _this.buildPath(file), cb);
          } catch (err) {
            return cb(new BuildError(file, err));
          }
        });
      }
    };

    return CoffeeBuilder;

  })();

  /*
  JS file builder
  */

  JSBuilder = (function() {

    __extends(JSBuilder, Builder);

    function JSBuilder() {
      JSBuilder.__super__.constructor.apply(this, arguments);
    }

    JSBuilder.prototype.fileExt = ".js";

    JSBuilder.prototype.reg = /^\/\/= import (.*)$/gm;

    JSBuilder.prototype._build = function(file, code, refresh, cb) {
      var _this = this;
      if (refresh && this.deps[file].refreshs.length) {
        return _.each(this.deps[file].refreshs, function(f, cb) {
          return _this.build(f, refresh, cb);
        }, function(err) {
          if (err) {
            return cb(new BuildError(file, err));
          } else {
            return cb(null);
          }
        });
      } else {
        return _.map(this.deps[file].imports, function(importFile, cb) {
          return fs.readFile(importFile, 'utf8', cb);
        }, function(err, imports) {
          if (err) return cb(new BuildError(file, err));
          code += imports.join('\n');
          return _this.write(code, _this.buildPath(file), cb);
        });
      }
    };

    return JSBuilder;

  })();

  /*
  Stylus preprocessor builder
  */

  StylusBuilder = (function() {

    __extends(StylusBuilder, Builder);

    function StylusBuilder() {
      StylusBuilder.__super__.constructor.apply(this, arguments);
    }

    StylusBuilder.prototype.reg = /^@import "(.*)"$/gm;

    StylusBuilder.prototype.fileExt = ".styl";

    StylusBuilder.prototype._build = function(file, code, refresh, cb) {
      var _this = this;
      return this._compile(file, code, function(err, css) {
        if (err) return cb(new BuildError(file, err));
        if (_this.deps[file].refreshs.length === 0) {
          return _this.write(css, _this.buildPath(file, '.css'), cb);
        } else if (refresh) {
          return _.each(_this.deps[file].refreshs, function(f, cb) {
            return _this.build(f, refresh, cb);
          }, function(err) {
            if (err) cb(new BuildError(file, err));
            return cb(null, file, "Compilation succeeded");
          });
        } else {
          return cb(null, file, "Compilation succeeded");
        }
      });
    };

    StylusBuilder.prototype._compile = function(file, code, cb) {
      return stylus(code).set('fileName', file).set('paths', [SQ.dir.root, SQ.dir.img, SQ.dir.root + "/public/images", path.dirname(file)]).use(nib())["import"]('nib').render(cb);
    };

    return StylusBuilder;

  })();

  builders = {
    '.coffee': new CoffeeBuilder,
    '.js': new JSBuilder,
    '.styl': new StylusBuilder,
    get: function(src) {
      return this[path.extname(src)];
    }
  };

  exports.build = function(src, cb) {
    return builders.get(src).build(src, true, cb);
  };

  exports.buildAll = function(files, cb) {
    return _.reduce(files, function(memo, stat, file, cb) {
      var builder;
      builder = builders.get(file);
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
  };

}).call(this);
