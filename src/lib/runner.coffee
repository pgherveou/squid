fs        = require 'fs'
path      = require 'path'
{argv}    = require('optimist').alias 'd', 'debug'
{spawn}   = require 'child_process'
moment    = require 'moment'

builder   = require "./projectBuilder"
{Monitor} = require "./finder"

logger    = require('./loggers').get 'util'
notifier  = require('./loggers').get 'notifier'


serverScript  = argv._[0] or 'index.js'
server        = null
startTime     = null
buildReady    = no

###
add an horizontal line after each log to make it easier to read
###

hrLogId = null

hrLog = () ->
  hr = ''
  hr += '.' for i in [1..50]
  console.log hr
  console.log moment().format 'h:mm:ss - ddd MMM YY'
  console.log hr

writeStdout = (data) ->
  process.stdout.write data
  clearTimeout hrLogId
  hrLogId = setTimeout hrLog, 3000

writeStderr = (data) ->
  process.stderr.write data
  clearTimeout hrLogId
  hrLogId = setTimeout hrLog, 3000

###
Server stuffs
###

srvArgs = []
srvArgs.push '--debug' if argv.debug
srvArgs.push serverScript

start = (msg = 'Starting') ->
  notifier.info msg, title: 'Server'
  startTime = moment()
  logger.info "starting #{srvArgs}"
  server = spawn 'node', srvArgs

  server.on 'exit', (err) ->
    return unless err
    notifier.error 'Server down', title: 'Server'
    restart()

  server.stdout.on 'data', writeStdout
  server.stderr.on 'data', writeStderr

restart = ->
  return unless server
  server.kill('SIGHUP')
  start 'Restarting' unless moment().diff(startTime, 'seconds') < 2

###
builder stuffs
###

srcMonitor = new Monitor 'src Monitor', path.resolve 'src'
libMonitor = new Monitor 'lib Monitor', path.resolve 'lib'

# display file relatively to the project root
relativeName = (file) -> file?.substring __dirname.length

# handle code change
codeChange = (err, file, message) ->
  return notifier.error(err.message, title: relativeName err.file) if err
  notifier.info message, title: relativeName(file) or srcMonitor.name

# configure and start srcMonitor
srcMonitor.on 'created', (f) -> builder.liveBuild f, codeChange
srcMonitor.on 'changed', (f) -> builder.liveBuild f, codeChange
srcMonitor.on 'removed', (f) -> builder.removeBuild f, codeChange
srcMonitor.once 'stopped',   -> notifier.info 'Stop monitor', title: srcMonitor.name

srcMonitor.once 'started', (files) ->
  notifier.debug "Watching", title: srcMonitor.name
  builder.liveBuildAll files, (errors) ->
    if errors
      notifier.error(e.message, title: relativeName(e.file)) for e in errors
    else
      notifier.debug 'Build done.', title: srcMonitor.name
      buildReady = yes
      start()

srcMonitor.start()

# configure and start libMonitor
libMonitor.once 'started', (files) ->
  notifier.debug "Watching", title: libMonitor.name

libMonitor.on 'changed', -> restart() if buildReady
libMonitor.on 'created', -> restart() if buildReady
libMonitor.once 'stopped', -> notifier.info 'Stop monitor', title: libMonitor.name
libMonitor.start()

###
process stuff
###

killApp = (code = 0) ->
  notifier.error 'Killing server...' if code
  srcMonitor?.stop()
  libMonitor?.stop()
  server.kill(code) if server
  process.exit(code)

process.on 'SIGINT',  killApp

process.on 'uncaughtException', (err) ->
  notifier.error "Caught exception: #{err}", err
  killApp(1)
