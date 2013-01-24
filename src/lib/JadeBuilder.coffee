path                  = require 'path'
async                 = require 'async'
jade                  = require 'jade'
{Builder, BuildError} = require './Builder'
logger                = require('./loggers').get 'util'

amdWrap = (fn) ->
  """
  define(['jade'], function(jade) {
    return #{fn.toString()};
  });
  """

module.exports = class JadeBuilder extends Builder

  reg    : /^include (.*)$/gm
  fileExt: '.jade'
  outExt : '.js'

  _build: (file, code, refresh, cb) ->

    if @deps[file].refreshs.length is 0

      try
        tplFn = jade.compile code, {filename: file, client  : true, compileDebug: false}
      catch error
        return cb new BuildError file, error

      data = if @config.jade.amd then amdWrap(tplFn) else tplFn.toString()
      @write data, file, cb

    else if refresh
      async.forEach @deps[file].refreshs,
        (f, cb) =>
          @build f,refresh, cb
        (err) ->
          return cb new BuildError(file, err) if err
          cb null, file, 'Compilation succeeded'

    else
      cb null, file, 'nothing to build'


