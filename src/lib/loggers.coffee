winston = require 'winston'
require 'winston-growl'

winston.loggers.add 'console',
  console:
    colorize:  on
    padLevels: on

winston.loggers.add 'notifier', growl: {}

module.exports = winston.loggers
