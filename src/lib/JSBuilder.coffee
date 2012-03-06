fs                    = require 'fs'
_                     = require 'nimble'
{Builder, BuildError} = require './Builder'


module.exports = class JSBuilder extends Builder

  fileExt: ".js"

  reg: /^\/\/= import (.*)$/gm

  _build: (file, code, refresh, cb) ->
    if refresh and @deps[file].refreshs.length
      _.each @deps[file].refreshs,
        (f, cb) =>  @build f, refresh, cb
        (err) -> if err then cb new BuildError file, err else cb null
    else
      _.map @deps[file].imports,
        (importFile, cb) -> fs.readFile importFile, 'utf8', cb
        (err, imports) =>
          return cb new BuildError file, err if err
          code += imports.join '\n'
          @write code, @buildPath(file), cb
