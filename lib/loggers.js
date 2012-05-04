var assetDir, growl, logFolder, path, winston,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

path = require('path');

winston = require('winston');

growl = require('growl');

/*
Custom growl logger
*/


assetDir = path.join(__dirname, '../assets');

winston.transports.Growl = (function(_super) {

  __extends(Growl, _super);

  Growl.name = 'Growl';

  function Growl() {
    return Growl.__super__.constructor.apply(this, arguments);
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

})(winston.Transport);

/*
Setup loggers container
*/


logFolder = path.join(__dirname, '../../data/log/');

winston.loggers.add('test', {
  console: {
    colorize: true,
    padLevels: true
  },
  file: {
    filename: path.join(logFolder, 'test.log')
  }
});

winston.loggers.add('app', {
  console: {
    colorize: true,
    padLevels: true,
    timestamp: true
  },
  file: {
    filename: path.join(logFolder, 'app.log')
  }
});

winston.loggers.add('util', {
  console: {
    colorize: true,
    padLevels: true
  }
});

winston.loggers.add('notifier', {
  growl: {}
});

module.exports = winston.loggers;
