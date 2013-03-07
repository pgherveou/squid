path                  = require 'path'
fs                    = require 'fs'
mkdirp                = require 'mkdirp'
OptiPng               = require 'optipng'
{Builder, BuildError} = require './Builder'

optimizer = new OptiPng

module.exports = class CSSBuilder extends Builder

  fileExt: '.png'
  outExt : '.png'

  constructor: ->
    super
    @pngConfig = @config.builders.png

  build: (src, refresh, cb) ->
    out = @buildPath src
    mkdirp path.dirname(out), 0o0755, (err) =>
      return cb new BuildError(out, err) if err
      srcStream = fs.createReadStream src
      outStream = fs.createWriteStream out
      srcStream.pipe(optimizer).pipe(outStream)
      outStream.on 'close', cb


