fs = require 'fs'
util = require 'util'
{Builder, BuildError} = require './Builder'

module.exports = class CopyBuilder extends Builder

	build: (src, refresh, cb) ->
	  srcStream  = fs.createReadStream src
	  outStream = fs.createWriteStream @buildPath file, @outDir
	  srcStream.once 'open', -> util.pump srcStream, outStream, cb



