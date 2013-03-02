{Builder, BuildError} = require './Builder'

module.exports = class JSONBuilder extends Builder

  fileExt: '.json'
  outExt : '.json'

  _build: (file, code, refresh, cb) ->
    try
      JSON.parse code
      @write code, file, cb
    catch err
      cb new BuildError file, err
