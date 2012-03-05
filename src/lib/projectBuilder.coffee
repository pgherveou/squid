CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
StylusBuilder = require './StylusBuilder'
_             = require 'nimble'

module.exports =

  '.coffee': new CSBuilder 'src', 'lib'
  '.js'    : new JSBuilder 'src', 'lib'
  '.styl'  : new StylusBuilder 'src', 'lib'

  get: (src) ->
    @[path.extname src]

  build: (src) ->
    @get(path.extname src).build src, true, cb

  buildAll: (files, cb) ->
    _.reduce files,
      (memo, stat, file, cb) ->
        builder = @get(file)
        return cb null, memo unless builder
        builder.build file, false, (err) ->
          memo.push new BuildError(file, err) if err
          cb null, memo
      []
      (err, errors) ->
        if errors then cb errors else cb null

