fs        = require 'fs'
path      = require 'path'
{spawn}   = require 'child_process'
moment    = require 'moment'
_         = require 'lodash'
{argv}    = require('optimist').alias('d', 'debug').alias('b', 'break')

logger    = require('./loggers').get 'util'
notifier  = require('./loggers').get 'notifier'
builder   = require './projectBuilder'
{Monitor} = require './finder'

server  = null
hrLogId = null

###
add an horizontal line after each log to make it easier to read
###

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
serverScript = builder.config.server.script

srvArgs.push '--debug' if argv.debug
srvArgs.push '--debug-brk' if argv.break
srvArgs.push path.resolve(__dirname, 'sqmon.js')

if (fs.existsSync serverScript)
  start = (msg = 'Starting') ->
    notifier.info msg, title: 'Server'
    server = spawn 'node', srvArgs, {cwd: '.', env: _(process.env).extend(builder.config.server.env, SQ_SCRIPT: serverScript)}
    server.stdout.on 'data', writeStdout
    server.stderr.on 'data', writeStderr
    server.once 'exit', (err) ->  start('Restarting') unless err

###
builder stuffs
###

# display file relatively to the project root
root = path.resolve '.'
relativeName = (file) -> file?.substring root.length

# handle code change
codeChange = (err, file, message) ->
  return notifier.error(err.toString(), title: relativeName err.file) if err
  notifier.info message, title: relativeName(file) or srcMonitor.name

# configure and start srcMonitor
srcMonitor = new Monitor 'src Monitor', path.resolve(builder.config.src), builder.config.filter
srcMonitor.on 'created', (f) -> builder.liveBuild(f, codeChange) if builder.config.fileFilter(f)
srcMonitor.on 'changed', (f) -> builder.liveBuild f, codeChange
srcMonitor.on 'removed', (f) -> builder.removeBuild f, codeChange

srcMonitor.once 'started', (files) ->

  # start server
  start?()

  # start watching
  notifier.info "Watching", title: srcMonitor.name
  builder.liveBuildAll files, (errors) ->
    if errors
      notifier.error(e.toString(), title: relativeName(e.file)) for e in errors
    else
      notifier.info 'Build done.', title: srcMonitor.name
srcMonitor.start()

###
process stuff
###

process.on 'SIGINT', (err) ->
  if server
    notifier.error 'Killing server...'
    server.kill 'SIGQUIT'
  process.exit()

