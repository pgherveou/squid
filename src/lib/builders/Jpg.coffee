path     = require 'path'
fs       = require 'fs'
mkdirp   = require 'mkdirp'
JpegTran = require 'jpegtran'
{Builder, BuildError} = require './Builder'

optimizer = new JpegTran

module.exports = class JPEGBuilder extends Builder

  fileExt: '.jpg'
  outExt : '.jpg'

  constructor: ->
    super
    @pngConfig = @config.builders.jpeg

  build: (src, refresh, cb) ->
    out = @buildPath src
    mkdirp path.dirname(out), 0o0755, (err) =>
      return cb new BuildError(out, err) if err
      srcStream = fs.createReadStream src
      outStream = fs.createWriteStream out
      srcStream.pipe(optimizer).pipe(outStream)
      outStream.on 'close', cb


