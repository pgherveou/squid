path                  = require 'path'
{CSSLint}             = require 'csslint'
{Builder, BuildError} = require './Builder'

module.exports = class CSSBuilder extends Builder

  fileExt: '.css'
  outExt : '.css'

  constructor: ->
    super
    @cssConfig = @config.builders.css

  _build: (file, code, refresh, cb) ->
    error = CSSLint.verify(code).messages
      .filter((msg)-> msg.type is 'error')
      .map((msg) -> "line #{msg.line}: #{msg.message}")
      .join '\n'

    return cb new BuildError(file, error) if error
    @write code, file, cb



