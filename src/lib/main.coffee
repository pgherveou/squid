require "./loggers"

fs        = require 'fs'
path      = require 'path'
{argv}    = require('optimist').alias 'd', 'debug'
{spawn}   = require 'child_process'
moment    = require 'moment'

builder   = require "./builder"
{Monitor} = require "./finder"

serverScript  = argv._[0] or 'index.js'
server        = null
startTime     = null
buildReady    = no

###
add an horizontal line after each log to make the log easier to read
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
  return unless buildReady and debuggerReady
  notifier.info msg, title: 'Server'
  startTime = moment()
  spawn 'node', srvArgs

  server 'exit', (err) ->
    return unless err
    notifierror 'Server down', title: 'Server'
    restart()

  server.stdout.on 'data', writeStdout
  server.stderr.on 'data', writeStderr

restart = ->
  server.kill('SIGHUP')
  start('Restarting') unless moment().diff(startTime, 'seconds') < 2

###
builder stuffs
###

srcMonitor = new Monitor 'src Monitor', 'src'
libMonitor = new Monitor 'lib Monitor', 'lib'

# display file relatively to the project root
relativeName = (file) -> file?.substring __dirname.length

# configure and start srcMonitor
srcMonitor.once 'started', (files) ->
  notifier.debug "Watching #{srcMonitor.name}", title: srcMonitor.name
  builder.buildAll files, (errors) ->
    if errors.length
      notifier.error(e.message, title: relativeName(e.file)) for e in errors
    else
      notifier.debug 'Build done.', title: srcMonitor.name
      if srcMonitor is serversrcMonitor
        buildReady = yes
        start()

# handle codechange
codeChange = (err, file, message) ->
  return notifier.error(err.message, title: relativeName err.file) if err
  notifier.info message, title: relativeName file

srcMonitor.on 'created', (f) -> builder.build f, codeChange
srcMonitor.on 'changed', (f) -> builder.build f, codeChange
srcMonitor.on 'removed', (f) -> builder.destroy f, codeChange
srcMonitor.once 'stopped',   -> notifier.info 'Stop monitor', title: srcMonitor.name
srcMonitor.start()

# configure and start libMonitor
libMonitor.on 'changed', restart
libMonitor.once 'stopped', -> notifier.info 'Stop monitor', title: libMonitor.name
libMonitor.start()

###
process stuff
###

start()

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






