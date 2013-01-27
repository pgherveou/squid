path                  = require 'path'
os                    = require 'os'
async                 = require 'async'
stylus                = require 'stylus'
nib                   = require 'nib'
{Builder, BuildError} = require './Builder'
logger                = require('./loggers').get 'util'

module.exports = class StylusBuilder extends Builder

  reg: /^@import "(.*)"$/gm

  fileExt: '.styl'
  outExt : '.css'

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
    paths = @config.stylus.paths
    stylus(code)
      .set('fileName', file)
      .set('compress', on)
      .define('env', process.env.NODE_ENV or 'development')
      .define('host', os.hostname())
      .set('paths', paths.concat(path.dirname file))
      .define('url', stylus.url @config.url)
      .use(nib())
      .import('nib')
      .render cb
