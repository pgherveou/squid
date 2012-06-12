fs                    = require 'fs'
path                  = require 'path'
async                 = require 'async'
cs                    = require 'coffee-script'
{Builder, BuildError} = require './Builder'
logger                = require('./loggers').get 'util'

module.exports = class CoffeeBuilder extends Builder

  fileExt: ".coffee"
  reg: /^#= import (.*)$/gm

  _build: (file, code, refresh, cb) ->
    if refresh and @deps[file].refreshs.length
      async.forEach @deps[file].refreshs,
        (f, cb) =>  @build f, refresh, cb
        (err) -> if err then cb new BuildError file, err else cb null
    else
      async.map @deps[file].imports,
        (importFile, cb) ->
          fs.readFile importFile, 'utf8', (err, data) ->
            return cb err if err
            if path.extname(importFile) is '.coffee'
              cb null, data
            else if path.extname(importFile) is '.js'
              data = data.replace /`/g, ''
              cb null, "`#{data}`"
            else
              cb new BuildError(importFile, 'file extension not supported')

        (err, imports) =>
          return  cb new BuildError file, err if err
          code = imports.join('\n') + code
          try
            js = cs.compile code, bare: true
            @write js, @buildPath(file), cb
          catch err
            cb new BuildError file, err
