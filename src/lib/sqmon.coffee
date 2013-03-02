moment    = require('moment')
path      = require('path')
util      = require('util')
fs        = require('fs')
notifier  = require('./loggers').get('notifier')
Monitor   = require('./finder').Monitor
startTime = moment()

if script = process.env.SQ_SCRIPT
  md = require(path.resolve(script))
else
  notifier.error("can not load " + script)
  process.exit(1)

if fs.existsSync('lib')
  libMonitor = new Monitor('lib Monitor', path.resolve('lib'))
  libMonitor.on 'changed', (f) -> process.exit(0) if f in Object.keys(require.cache)
  libMonitor.start()

process.on 'uncaughtException', (err) ->
  console.log err
  notifier.error err.toString(), title: "Exception"
  if moment().diff(startTime, 'seconds') < 2
    process.exit(0)
  else
   process.exit(1)
