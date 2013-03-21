path                  = require 'path'
os                    = require 'os'
async                 = require 'async'
stylus                = require 'stylus'
nib                   = require 'nib'
{Builder, BuildError} = require './Builder'

module.exports = class StylusBuilder extends Builder

  reg: /^@import "(.*)"$/gm

  fileExt: '.styl'
  outExt : '.css'

  constructor: ->
    super
    @stylusConfig = @config.builders.stylus

  _build: (file, code, refresh, cb) ->

    if @deps[file].refreshs.length is 0
      @_compile file, code, (err, css) =>
        return cb new BuildError(file, err) if err
        @write css, file, cb

    else if refresh
      async.forEach @deps[file].refreshs,
        (f, cb) =>
          @build f,refresh, cb
        (err) ->
          return cb new BuildError(file, err) if err
          cb null, file, 'Compilation succeeded'

    else
      cb null, file, 'nothing to build'

  _compile: (file, code, cb) =>
    compiler = stylus(code)
      .set('fileName', file)
      .set('compress', on)
      .define('env', process.env.NODE_ENV or 'development')
      .define('host', os.hostname())
      .set('paths', @stylusConfig.paths.concat(path.dirname file))

    if @stylusConfig.url
      compiler.define('url', stylus.url(@stylusConfig.url))

    if @stylusConfig.nib
      compiler.use(nib()).import('nib')

    if @stylusConfig.imports
      compiler.use(nib()).import(i) for i in @stylusConfig.imports

    compiler.render cb
