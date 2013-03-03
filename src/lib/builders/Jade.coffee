path                  = require 'path'
async                 = require 'async'
jade                  = require 'jade'
{Builder, BuildError} = require './Builder'

amdWrap = (fn) ->
  """
  define(['jade'], function(jade) {
    return #{fn};
  });
  """

fnWrap = (fn) ->
  """
    function (locals) {
      if (locals == null) {locals = {};}
      jade.merge(locals, jade.helpers || {});
      return #{fn}(locals)
    }
  """

module.exports = class JadeBuilder extends Builder

  reg    : /^include (.*)$/gm
  fileExt: '.jade'
  outExt : '.js'

  constructor: ->
    super
    @jadeConfig = @config.builders.jade


  _build: (file, code, refresh, cb) ->

    if @deps[file].refreshs.length is 0
      try
        compileOpts = filename: file, client: true, compileDebug: false
        tplFn = jade.compile(code, compileOpts).toString()
      catch error
        return cb new BuildError file, error

      tplFn = fnWrap(tplFn) if @jadeConfig.helpers
      tplFn = amdWrap(tplFn) if @jadeConfig.amd
      @write tplFn, file, cb

    else if refresh
      async.forEach @deps[file].refreshs,
        (f, cb) =>
          @build f,refresh, cb
        (err) ->
          return cb new BuildError(file, err) if err
          cb null, file, 'Compilation succeeded'

    else
      cb null, file, 'nothing to build'


