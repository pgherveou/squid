(function() {
  var assetDir, growl, notifierOpts, path, winston;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  path = require('path');

  winston = require('winston');

  growl = require('growl');

  /*
  Custom growl logger
  */

  assetDir = path.join(path.dirname(require.main.filename), '../assets');

  winston.transports.Growl = (function() {

    __extends(Growl, winston.Transport);

    function Growl() {
      Growl.__super__.constructor.apply(this, arguments);
    }

    Growl.prototype.name = 'growl';

    Growl.prototype.levelImages = {
      debug: path.join(assetDir, 'sq-info.png'),
      info: path.join(assetDir, 'sq-info.png'),
      warn: path.join(assetDir, 'sq-warn.png'),
      error: path.join(assetDir, 'sq-error.png')
    };

    Growl.prototype.log = function(level, msg, meta, callback) {
      growl(msg != null ? msg.toString().slice(0, 41) : void 0, {
        title: (meta != null ? meta.title : void 0) || 'Log',
        image: this.levelImages[level]
      });
      return callback(null, true);
    };

    return Growl;

  })();

  /*
  Loggers customization
  */

  winston.loggers.add('logger', {
    console: {
      colorize: true,
      padLevels: true
    }
  });

  if (process.env.NODE_ENV === 'development') {
    notifierOpts = {
      growl: {},
      console: {
        colorize: true,
        padLevels: true
      }
    };
  } else {
    notifierOpts = {
      console: {
        colorize: true,
        padLevels: true
      }
    };
  }

  winston.loggers.add('notifier', notifierOpts);

  global.notifier = winston.loggers.get('notifier');

  global.logger = winston.loggers.get('logger');

}).call(this);
