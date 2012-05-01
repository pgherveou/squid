path   = require 'path'
fs     = require 'fs'
util   = require 'util'
async  = require 'async'
zlib   = require 'zlib'


logger = require('./loggers').get 'util'
{walk} = require './finder'


module.exports =

  publish: (opts, cb)  ->

    # set default filter
    opts.filter or= -> true

    # ensure root dir is specifed
    return cb new Error 'no folder specified' unless opts.dir

    logger.info "uploading new files from #{opts.dir}"

    walk opts.dir, opts.filter, (err, files) =>
      return logger.error err if err
      logger.info "#{files.length} to upload"

      async.forEach files, @publishFile, (err) ->
        logger.error "Error publishing files ", err if err
        logger.info "publication done for #{opts.dir}"

  publishFile: (file, cb) ->

  putZipFile: (src, filename, cb) ->

    fs.readFile filename, (err, buf) ->
      cb new Error "Error reading #{filename}" if err
      zlib.gzip buf, (err, zip) ->
        cb new Error "Error zipping #{filename}" if err

        req = client.put '/test/Readme.md',
          'Content-Encoding': 'gzip'
          'Content-Length'  : zip.length
          'Content-Type'    : mime.lookup filename

        req.on 'response', (res) ->
          if res.statusCode is 200
            console.log "saved to #{req.url}"
          else
            console.log "error status code is #{res.statusCode}"

        req.end zip
