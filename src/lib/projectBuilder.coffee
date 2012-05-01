path          = require 'path'
fs            = require 'fs'
util          = require 'util'
async         = require 'async'

{walk}        = require './finder'
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
JadeBuilder   = require './JadeBuilder'
StylusBuilder = require './StylusBuilder'

logger        = require('./loggers').get 'util'

# builder factory
buildFactory =
  get: (file) -> @[path.extname file]
  '.coffee': new CSBuilder 'src', '.'
  '.js'    : new JSBuilder 'src', '.'
  '.styl'  : new StylusBuilder 'src', '.'
  '.jade'  : new JadeBuilder 'src', '.'

module.exports =

  buildAll: (exceptFolders = [], cb)  ->

    cb or= (errors) ->
      if errors
        logger.error e.toString() for e in errors
      else
        logger.info "Build done."

    filter = (f, stat) ->
      return false if stat.isDirectory() and path.basename(f) in exceptFolders
      return true if stat.isDirectory()
      return /\.(coffee|js|styl|jade)$/.test(f)

    walk "src", filter, (err, files) =>
      return logger.error err if err
      @liveBuildAll files, cb

  removeBuild: (file, cb) ->
    buildFactory.get(file).removeBuild file, cb

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
        # logger.debug 'build ' + file
        errors.push err if err
        cb null

    async.forEach files, buildFile, ->
      # logger.debug 'build done'
      if errors.length then cb errors else cb null
