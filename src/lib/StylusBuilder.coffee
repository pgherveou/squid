path                  = require 'path'
async                 = require 'async'
stylus                = require 'stylus'
nib                   = require 'nib'
{Builder, BuildError} = require './Builder'
logger                = require('./loggers').get 'util'

module.exports = class StylusBuilder extends Builder

  reg: /^@import "(.*)"$/gm

  fileExt: ".styl"

  _build: (file, code, refresh, cb) ->

    if @deps[file].refreshs.length is 0
      @_compile file, code, (err, css) =>
        return cb new BuildError(file, err) if err
        @write css, @buildPath(file, '.css'), cb

    else if refresh
      async.each @deps[file].refreshs,
        (f, cb) =>
          @build f,refresh, cb
        (err) ->
          return cb new BuildError(file, err) if err
          cb null, file, 'Compilation succeeded'

    else
      cb null, file, 'nothing to build'

  _compile: (file, code, cb) ->
    stylus(code)
      .set('fileName', file)
      .set('compress', on)
      .set('paths', ['public/images', path.dirname file])
      .define('url', stylus.url({ paths: ['public'] }))
      .use(nib())
      .import('nib')
      .render cb
