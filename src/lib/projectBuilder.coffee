path   = require 'path'
fs     = require 'fs'
util   = require 'util'
async  = require 'async'
_      = require 'lodash'
{exec} = require 'child_process'

logger        = require('./loggers').get 'util'

{walk}        = require './finder'
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
JadeBuilder   = require './JadeBuilder'
StylusBuilder = require './StylusBuilder'

config =
  src: 'src'
  out: '.'
  clone: []
  mappings: []
  coffee: {}
  jade:
    amd: yes
  stylus:
    url: ['public']
    paths: ['public/images']

# setup config
if fs.existsSync 'squid.json'
  fileConfig = JSON.parse(fs.readFileSync 'squid.json')
  config = _(fileConfig).defaults(config)

# setup post script if any
if config.post_build
  config.post_build.match = new RegExp config.post_build.match

# setup clone if any
config.clone.forEach (clone) -> clone.match = new RegExp(clone.match)

# builder factory
buildFactory =
  get: (file) -> @[path.extname file]
  '.coffee': new CSBuilder config
  '.js'    : new JSBuilder config
  '.styl'  : new StylusBuilder config
  '.jade'  : new JadeBuilder config

# post build
postBuild = ->
  postBuild.process?.kill()
  postBuild.process = exec config.post_build.cmd, -> postBuild.process = null


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

  liveBuild: (src, cb) ->
    buildFactory.get(src).build src, true, (err, file, message) ->
      cb err, file, message
      return if err or /identical/.test message
      postBuild() if config.post_build and config.post_build.match.test(src)


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

    async.forEach files, buildFile, ->
      return cb errors if errors.length
      cb()
      postBuild() if config.post_build


