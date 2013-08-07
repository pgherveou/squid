path                  = require 'path'
handlebars            = require 'handlebars'
{Builder, BuildError} = require './Builder'

module.exports = class HandleBarsBuilder extends Builder

  fileExt: '.hbs'
  outExt : '.js'

  commonJSWrap = (fn) ->
    """
    var Handlebars = require('handlebars');
    module.exports = Handlebars.template(#{fn});
    """

  amdWrap = (fn) ->
    """
    define(['handlebars'], function(Handlebars) {
      return Handlebars.template(#{fn});
    });
    """

  constructor: ->
    super
    @hbsConfig = @config.builders.handlebars

  _build: (file, code, refresh, cb) ->
    try
      tplFn = handlebars.precompile(code).toString()
      switch @hbsConfig.wrap
        when 'amd'      then tplFn = amdWrap tplFn
        when 'commonJS' then tplFn = commonJSWrap tplFn
      @write tplFn, file, cb
    catch error
      cb new BuildError file, error



