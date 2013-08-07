fs                 = require 'fs'
path               = require 'path'
{spawn}            = require 'child_process'
moment             = require 'moment'
_                  = require 'lodash'
{Monitor}          = require 'findr'
{argv}             = require('optimist').alias('d', 'debug').alias('b', 'break')
project            = require './project'
{logger, notifier} = require './loggers'

script  = null
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

unless process.env.NO_SCRIPT
  scriptName = process.env.SQ_SCRIPT or project.config.server.script

if (scriptName)
  start = (msg) ->
    msg or= "Starting script #{scriptName}"
    notifier.info msg, title: scriptName

    if (path.extname(scriptName) is '.js')
      srvArgs.push '--debug' if argv.debug
      srvArgs.push '--debug-brk' if argv.break
      srvArgs.push path.resolve(__dirname, 'scriptWrapper.js')
      script = spawn 'node', srvArgs, {cwd: '.', env: _.extend(process.env, project.config.server.env, SQ_SCRIPT: scriptName)}
      script.once 'exit', (err) ->  start("Restarting script #{scriptName}") unless err
    else
      script = spawn scriptName

    script.stdout.on 'data', writeStdout
    script.stderr.on 'data', writeStderr




else
  start = ->

###
builder stuffs
###

# display file relatively to the project root
root = path.resolve '.'
relativeName = (file) -> file?.substring root.length

# handle code change
codeChange = (err, file, newCode) ->
  return notifier.error(err.toString(), title: relativeName err.file) if err
  unless newCode
    return notifier.info "file unchanged", title: relativeName(file) or srcMonitor.name

  notifier.info "file compiled sucessfully", title: relativeName(file) or srcMonitor.name

  if (scriptName and not script) or (script and script.exitCode isnt null)
    start("Restarting #{scriptName}")

# configure and start srcMonitor
srcMonitor = new Monitor 'src Monitor', path.resolve(project.config.src), project.filter
srcMonitor.on 'created', (f) -> project.liveBuild(f, codeChange) if project.fileFilter(f)
srcMonitor.on 'changed', (f) -> project.liveBuild f, codeChange
srcMonitor.on 'removed', (f) -> project.removeBuild f, codeChange

srcMonitor.once 'started', (files) ->
  notifier.info "Watching", title: srcMonitor.name
  project.liveBuildAll files, (errors) ->
    if errors
      notifier.error(e.toString(), title: relativeName(e.file)) for e in errors
    else
      notifier.info 'Build done.', title: srcMonitor.name
      start() if scriptName
srcMonitor.start()

###
process stuff
###

process.on 'SIGINT', (err) ->
  if script
    notifier.error 'Killing script...', title: scriptName
    script.kill 'SIGQUIT'
  process.exit()
