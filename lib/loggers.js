var winston;

winston = require('winston');

require('winston-growl');

winston.loggers.add('console', {
  console: {
    colorize: true,
    padLevels: true
  }
});

winston.loggers.add('notifier', {
  growl: {}
});

module.exports = winston.loggers;
