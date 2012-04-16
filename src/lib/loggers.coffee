path    = require 'path'
winston = require 'winston'
growl   = require 'growl'

###
Custom growl logger
###

assetDir = path.join __dirname, '../assets'

class winston.transports.Growl extends winston.Transport

  name: 'growl'

  levelImages:
    debug: path.join assetDir, 'sq-info.png'
    info : path.join assetDir, 'sq-info.png'
    warn : path.join assetDir, 'sq-warn.png'
    error: path.join assetDir, 'sq-error.png'

  log: (level, msg, meta, callback) ->

    growl msg?.toString()[0..40],
      title: meta?.title or 'Log'
      image: @levelImages[level]

    callback null, true

###
Setup loggers container
###

logFolder = path.join __dirname, '../../data/log/'

winston.loggers.add 'test',
  console:
    colorize:  true
    padLevels: true
  file:
    filename: path.join logFolder, 'test.log'

winston.loggers.add 'app',
  console:
    colorize:  true
    padLevels: true
  file:
    filename: path.join logFolder, 'app.log'

winston.loggers.add 'landing',
  console:
    colorize:  true
    padLevels: true
  file:
    filename: path.join logFolder, 'landing.log'


winston.loggers.add 'proxy',
  console:
    colorize:  true
    padLevels: true
  file:
    filename: path.join logFolder, 'proxy.log'

winston.loggers.add 'util',
  console:
    colorize:  true
    padLevels: true

winston.loggers.add 'notifier', growl: {}

module.exports = winston.loggers
