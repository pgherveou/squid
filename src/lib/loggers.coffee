path    = require 'path'
winston = require 'winston'
growl   = require 'growl'

###
Custom growl logger
###

assetDir = path.join path.dirname(require.main.filename), 'assets'

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
Loggers customization
###

winston.loggers.add 'logger',
  console:
    colorize:  true
    padLevels: true

if process.env.NODE_ENV is 'development'
  notifierOpts =
    growl: {}
    console: colorize: true, padLevels: true
else
  notifierOpts = console: colorize: true, padLevels: true

winston.loggers.add 'notifier', notifierOpts


global.notifier = winston.loggers.get 'notifier'
global.logger   = winston.loggers.get 'logger'
