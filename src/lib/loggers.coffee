winston = require 'winston'
require 'winston-growl'

###
Setup loggers container
###


winston.loggers.add 'util',
  console:
    colorize:  on
    padLevels: on

winston.loggers.add 'notifier', growl: {}

module.exports = winston.loggers
