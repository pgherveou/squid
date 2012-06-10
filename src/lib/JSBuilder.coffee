fs                    = require 'fs'
async                 = require 'async'
{Builder, BuildError} = require './Builder'
logger                = require('./loggers').get 'util'

module.exports = class JSBuilder extends Builder

  fileExt: ".js"

  reg: /^\/\/= import (.*)$/gm

  _build: (file, code, refresh, cb) ->
    if refresh and @deps[file].refreshs.length
      async.forEach @deps[file].refreshs,
        (f, cb) =>  @build f, refresh, cb
        (err) -> if err then cb new BuildError file, err else cb null
    else
      async.map @deps[file].imports,
        (importFile, cb) -> fs.readFile importFile, 'utf8', cb
        (err, imports) =>
          return cb new BuildError file, err if err
          code += imports.join '\n'
          @write code, @buildPath(file), cb
