path          = require 'path'
fs            = require 'fs'
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
StylusBuilder = require './StylusBuilder'
_             = require 'nimble'


builders =
  '.coffee': new CSBuilder 'src', '.'
  '.js'    : new JSBuilder 'src', '.'
  '.styl'  : new StylusBuilder 'src', '.'

getBuilder = (file) -> builders[path.extname file]

module.exports =

  build: (file, cb) ->
    getBuilder(file).build file, true, cb

  buildAll: (fileItems, cb) ->

    files = (file for file of fileItems)

    # scan all
    logger.debug 'scan all ...'
    for file in files
      if builder = getBuilder(file)
        code = fs.readFileSync file, 'utf8'
        builder.scan file, code

    # build all
    errors = []

    buildFile = (file, cb) ->
      builder = getBuilder(file)
      return cb null unless builder
      builder.build file, false, (err) ->
        errors.push err if err
        cb null

    _.each files, buildFile, -> if errors.length then cb errors else cb null
