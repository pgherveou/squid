winston = require 'winston'
require 'winston-growl'

winston.loggers.add 'console',
  console:
    colorize:  on
    padLevels: on
    level : if process.env.DEBUG then 'debug' else 'info'

winston.loggers.add 'notifier', growl: {}

module.exports = winston.loggers
