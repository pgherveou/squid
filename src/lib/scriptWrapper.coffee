moment     = require 'moment'
path       = require 'path'
util       = require 'util'
fs         = require 'fs'
{Monitor}  = require 'findr'
{notifier} = require './loggers'

startTime = moment()

if script = process.env.SQ_SCRIPT
  md = require(path.resolve(script))
else
  notifier.error("no script specified")
  process.exit(1)

if fs.existsSync('lib')
  libMonitor = new Monitor('lib Monitor', path.resolve('lib'))
  libMonitor.on 'changed', (f) -> process.exit(0) if f in Object.keys(require.cache)
  libMonitor.start()

process.on 'uncaughtException', (err) ->
  notifier.error err.toString(), title: "Exception"
  if moment().diff(startTime, 'cents') < 500
    notifier.error "exception loop, shutting down script"
    process.exit(1)
  else
    notifier.info "restart script"
    process.exit(0)
