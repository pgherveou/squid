path          = require 'path'
fs            = require 'fs'
_             = require 'nimble'

{walk}        = require('./finder')
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
StylusBuilder = require './StylusBuilder'
logger        = require('./loggers').get 'util'

# builder factory
buildFactory =
  get: (file) -> @[path.extname file]
  '.coffee': new CSBuilder 'src', '.'
  '.js'    : new JSBuilder 'src', '.'
  '.styl'  : new StylusBuilder 'src', '.'

module.exports =

  buildAll: (exceptFolders = [])  ->

    filter = (f, stat) ->
      return false if stat.isDirectory() and path.basename(f) in exceptFolders
      return true if stat.isDirectory()
      return /\.(coffee|js|styl)$/.test(f)

    walk "src", filter, (err, files) ->
      builder.buildAll files, (errors) ->
        if errors
          errors.forEach (e) -> logger.error "file: " + e.file + ":\n " + e.message
        else
          logger.info "Build done."

  liveBuild: (file, cb) ->
    buildFactory.get(file).build file, true, cb

  liveBuildAll: (fileItems, cb) ->
    files = (file for file of fileItems)

    # scan all
    logger.debug 'scan all ...'
    for file in files
      if builder = buildFactory.get(file)
        code = fs.readFileSync file, 'utf8'
        builder.scan file, code

    # build all
    errors = []

    buildFile = (file, cb) ->
      builder = buildFactory.get(file)
      return cb null unless builder
      builder.build file, false, (err) ->
        errors.push err if err
        cb null

    _.each files, buildFile, -> if errors.length then cb errors else cb null
