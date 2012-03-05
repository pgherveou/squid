path                  = require 'path'
_                     = require 'nimble'
stylus                = require 'stylus'
nib                   = require 'nib'
{Builder, BuildError} = require './Builder'


module.exports = class StylusBuilder extends Builder

  reg: /^@import "(.*)"$/gm

  fileExt: ".styl"

  _build: (file, code, refresh, cb) ->

    if @deps[file].refreshs.length is 0
      # logger.debug "compiling: #{file} #{@deps[file].refreshs.length}"
      @_compile file, code, (err, css) =>
        return cb new BuildError(file, err) if err
        @write css, @buildPath(file, '.css'), cb

    else if refresh
      _.each @deps[file].refreshs,
        (f, cb) =>
          @build f,refresh, cb
        (err) ->
          cb new BuildError(file, err) if err
          cb null, file, "Compilation succeeded"

    else
      cb null, file, "nothing to build"

  _compile: (file, code, cb) ->
    stylus(code)
      .set('fileName', file)
      .set('paths', ['public/images', path.dirname file])
      .use(nib())
      .import('nib')
      .render cb
