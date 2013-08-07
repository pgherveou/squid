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

commonJSWrap = (fn) ->
  """
  var jade = require('jade');
  if (jade.runtime) {jade = jade.runtime;}
  module.exports = function (locals) {
    if (locals && jade.helpers) {(locals || (locals = {})).__proto__ = jade.helpers;}
    return #{fn}.apply(this, arguments);
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

      switch @jadeConfig.wrap
        when 'amd'      then tplFn = amdWrap tplFn
        when 'commonJS' then tplFn = commonJSWrap tplFn

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


