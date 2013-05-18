winston = require 'winston'
Growl   = require 'winston-growl'

level = if process.env.DEBUG then 'debug' else 'info'

module.exports =

	logger: new winston.Logger
	  transports: [
	  	new winston.transports.Console
	  		colorize: true
	  		padLevels: true
	  		level: level
	  ]

	notifier: new winston.Logger
		transports: [
			new Growl
	  	new winston.transports.Console
	  		colorize: true
	  		padLevels: true
	  		level: 'error'
		]


