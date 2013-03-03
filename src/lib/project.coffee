path           = require 'path'
fs             = require 'fs'
async          = require 'async'
{EventEmitter} = require 'events'
{walk}         = require 'findr'
logger         = require('./loggers').get 'console'

class Project extends EventEmitter

  constructor: ->
    # init config
    @config = require './config'

    # create file filter
    regStr  = builders.map((Builder) -> Builder::fileExt[1..]).join '|'
    fileReg = new RegExp "\\.(#{regStr})$"
    @fileFilter = (f) -> fileReg.test(f)
    @filter = (f, stat) -> stat.isDirectory() or config.fileFilter f

    # create build factory
    @buildFactory = {}
    @buildFactory[Builder::fileExt] = new Builder config for Builder in builders
    @buildFactory.get = (file) -> @[path.extname file]


  buildAll: (opts = {}, cb) ->
    if typeof opts is 'function'
      cb = opts
      opts = {}

    cb or= (errors) ->
      if errors
        logger.error e.toString() for e in errors
      else
        logger.info "Build done."

    filter = (f, stat) =>
      return false if stat.isDirectory() and (opts.except and path.basename(f) in opts.except)
      @config.filter f, stat

    walk @config.src, filter, (err, files) =>
      return logger.error err if err
      @liveBuildAll files, cb

  removeBuild: (file, cb) ->
    @buildFactory.get(file).removeBuild file, cb

  liveBuild: (src, cb) ->
    @buildFactory.get(src).build src, true, (err, file, newCode) ->
      cb err, file, newCode
      @emit 'file-build' if not err and newCode

  liveBuildAll: (fileItems, cb) ->
    files = (file for file of fileItems)
    errors = []

    logger.info 'scan all ...'
    for file in files
      if builder = @buildFactory.get(file)
        code = fs.readFileSync file, 'utf8'
        builder.scan file, code

    # build all
    buildFile = (file, cb) ->
      builder = @buildFactory.get(file)
      return cb null unless builder
      builder.build file, false, (err) ->
        errors.push err if err
        cb null

    async.forEach files, buildFile, ->
      cb(errors if errors.length)
      @emit 'project-build' unless errors.length

module.exports = new Project