path   = require 'path'
fs     = require 'fs'
util   = require 'util'
async  = require 'async'
_      = require 'lodash'
{exec} = require 'child_process'

logger        = require('./loggers').get 'util'

{walk}        = require 'findr'
CSBuilder     = require './CSBuilder'
JSBuilder     = require './JSBuilder'
JadeBuilder   = require './JadeBuilder'
StylusBuilder = require './StylusBuilder'
JSONBuilder   = require './JSONBuilder'
CopyBuilder   = require './CopyBuilder'

config =
  src: 'src'
  out: '.'
  server:
    script: 'index.js'
    env: {}
  clone: []
  mappings: []
  coffee: {}
  jade:
    amd: yes
  stylus:
    url: paths: ['public']
    paths: ['public/images']

# setup config
if fs.existsSync 'squid.json'
  fileConfig = JSON.parse(fs.readFileSync 'squid.json')
  config = _(fileConfig).defaults(config)

# setup post script if any
if config.post_build
  config.post_build.match = new RegExp config.post_build.match or ''

# setup clone if any
config.clone.forEach (clone) -> clone.match = new RegExp(clone.match)

# setup filters
config.fileFilter = (f) -> /\.(js|coffee|styl|jade|json)$/.test(f)
config.filter = (f, stat) -> stat.isDirectory() or config.fileFilter f

# builder factory
buildFactory =
  '.js'    : new JSBuilder config
  '.coffee': new CSBuilder config
  '.styl'  : new StylusBuilder config
  '.jade'  : new JadeBuilder config
  '.json'  : new JSONBuilder config
  get: (file) ->
    @[path.extname file] or @copy

# post build
postBuild = ->
  postBuild.process?.kill()
  postBuild.process = exec config.post_build.cmd, (err, stdout, stderr) ->
    console.log stdout + stderr
    postBuild.process = null

module.exports =

  config: config

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
      config.filter f, stat

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


