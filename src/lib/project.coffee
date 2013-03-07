path           = require 'path'
fs             = require 'fs'
async          = require 'async'
{EventEmitter} = require 'events'
{walk}         = require 'findr'
builders       = require './builders'
logger         = require('./loggers').get 'console'

class Project extends EventEmitter

  constructor: ->
    # init config
    @config = require './config'

    # create file filter
    regStr  = builders.map((Builder) -> Builder::fileExt[1..]).join '|'
    fileReg = new RegExp "\\.(#{regStr})$"
    @fileFilter = (f) -> fileReg.test(f)
    @filter = (f, stat) => stat.isDirectory() or @fileFilter f

    # create build factory
    @buildFactory = {}
    @buildFactory[Builder::fileExt] = new Builder @config for Builder in builders
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

    buildFilter = (f, stat) =>
      return false if stat.isDirectory() and (opts.except and path.basename(f) in opts.except)
      @filter f, stat

    walk @config.src, buildFilter, (err, files) =>
      return logger.error err if err
      @liveBuildAll files, cb

  removeBuild: (file, cb) =>
    @buildFactory.get(file).removeBuild file, cb

  liveBuild: (src, cb) =>
    @buildFactory.get(src).build src, true, (err, file, newCode) =>
      cb err, file, newCode
      @emit('build', src) if not err and newCode

  liveBuildAll: (fileItems, cb) =>
    files = Object.keys fileItems
    errors = []

    files.forEach (file) =>
      if builder = @buildFactory.get(file)
        code = fs.readFileSync file, 'utf8'
        builder.scan file, code

    # build all
    buildFile = (file, cb) =>
      return cb null unless builder = @buildFactory.get(file)
      fs.stat builder.buildPath(file), (err, stat) ->
        return cb null if not err and stat.mtime.getTime() > fileItems[file].mtime.getTime()
        builder.build file, false, (err) ->
          errors.push err if err
          cb null

    async.forEach files, buildFile, =>
      cb(errors if errors.length)
      @emit 'build' unless errors.length

project = new Project
require('./middlewares/post-build') project

module.exports = project