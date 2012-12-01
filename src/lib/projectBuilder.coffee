path          = require 'path'
fs            = require 'fs'
util          = require 'util'
async         = require 'async'
_             = require 'lodash'

logger        = require('./loggers').get 'util'

{walk}        = require './finder'
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
JadeBuilder   = require './JadeBuilder'
StylusBuilder = require './StylusBuilder'

config =
  src: 'src'
  build: '.'
  mappings: []
  coffee: {}
  jade:
    amd: yes
  stylus:
    url: ['public']
    paths: ['public/images']


if fs.existsSync 'squid.json'
  fileConfig = JSON.parse(fs.readFileSync 'squid.json')
  _(config).extend fileConfig


# builder factory
buildFactory =
  get: (file) -> @[path.extname file]
  '.coffee': new CSBuilder config
  '.js'    : new JSBuilder config
  '.styl'  : new StylusBuilder config
  '.jade'  : new JadeBuilder config

module.exports =

  buildAll: (opts = {}, cb) ->

    if typeof opts is 'function'
      cb = opts
      opts = {}

    cb or= (errors) ->
      if errors
        logger.error e.toString() for e in errors
      else
        logger.info "Build done."

    filter = (f, stat) ->
      return false if stat.isDirectory() and (opts.except and path.basename(f) in opts.except)
      return true if stat.isDirectory()
      return /\.(coffee|js|styl|jade)$/.test(f)

    walk config.src, filter, (err, files) =>
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
