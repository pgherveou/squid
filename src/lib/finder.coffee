fs     = require 'fs'
path   = require 'path'
events = require 'events'
_      = require 'underscore'

exports.walk = walk = (dir, filter, fn) ->

  # just to be safe
  dir = path.resolve dir

  if arguments.length is 2
    fn = filter
    filter = -> true

  fn.files ?= {}
  try fn.files[dir] = fs.statSync(dir) catch err then fn err

  traverse = (dir) ->
      try files = fs.readdirSync(dir) catch err then fn err
      files.forEach (filename) ->
        file = path.join dir, filename
        try stat = fs.statSync(file) catch err then fn err
        return unless filter and filter filename, stat
        fn.files[file] = stat
        traverse file if stat.isDirectory()

  traverse dir
  fn null, fn.files

exports.watch = watch = (dir, filter, fn) ->

  walk dir, filter, (err, files) ->
    return console.error err if err

    watcher = (f) ->
      fs.watchFile f, interval: 50, persistent: true, (curr, prev) ->
        return if files[f] and files[f].isFile() and curr.nlink isnt 0 and curr.mtime.getTime() is prev.mtime.getTime()
        files[f] = curr

        if files[f].isFile() then fn f, curr, prev

        else if curr.nlink isnt 0
          fs.readdir f, (err, dirFiles) ->
            return console.error "err loading #{f} : #{err}" if err
            _(dirFiles).each (filename) ->
              file = path.join f, filename
              unless files[file]
                fs.stat file, (err, stat) ->
                  return console.error "err loading #{file} : #{err}" if err
                  if filter file, stat
                    fn file, stat, null
                    files[file] = stat
                    watcher file

        if curr.nlink is 0
          delete files[f]
          fs.unwatchFile f

    watcher file for file of files
    fn files, null, null

class exports.Monitor extends events.EventEmitter

  constructor: (@name, @dir, @filter) ->
    @state = 'stopped'
    @files = {}

  start: ->
    return unless @state is 'stopped'
    @state = 'running'
    watch @dir, @filter, (f, curr, prev) =>
      if curr is null and prev is null
        _(@files).extend f
        @emit 'started', @files
      else if prev is null
        @emit 'created', f, curr, prev
      else if curr.nlink is 0
        @emit 'removed', f, curr, prev
      else
        @emit 'changed', f, curr, prev

  stop: ->
    return unless @state is 'running'
    @state = 'stopped'
    for file of @files
      fs.unwatchFile file
    @emit 'stopped'
