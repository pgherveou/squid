path    = require 'path'
winston = require 'winston'
growl   = require 'growl'
require 'winston-growl'

###
Setup loggers container
###

logFolder = path.join __dirname, '../../data/log/'


winston.loggers.add 'util',
  console:
    colorize:  on
    padLevels: on

winston.loggers.add 'notifier', growl: {}

module.exports = winston.loggers
