path   = require 'path'
fs     = require 'fs'
zlib   = require 'zlib'
crypto = require 'crypto'
knox   = require 'knox'
mime   = require 'mime'
async  = require 'async'
_      = require 'lodash'
moment = require 'moment'

logger = require('./loggers').get 'util'
{walk} = require './finder'

# default expires header set to year + 10
expireDate = moment().add('years', 10).format('ddd, DD MMM YYYY') + " 12:00:00 GMT"

module.exports =

  class Publisher

    constructor: (config) ->
      @client = knox.createClient config

    publishDir: ({origin, dest, filter}, cb)  ->

      # add slash
      dest = "/#{dest}" if dest and dest[0] isnt '/'

      # set default filter
      filter or= -> true

      # convert origin folder to absolute
      origin = path.join path.resolve(origin)
      logger.info "uploading new files from '#{origin}' to '#{dest}'"


      walk origin, filter, (err, fileItems) =>
        return logger.error err if err
        files = (file for file, stat of fileItems when stat.isFile())

        # create a task queue to upload file
        q = async.queue @publish, 2
        q.drain =  ->
          logger.debug "All files were uploaded"
          cb()

        files.forEach (file) =>
          filename = file.replace origin, dest
          q.push {file, filename}, ->

    publish: ({file, filename}, cb) =>

      async.waterfall [

        # readfile
        (cb) -> fs.readFile file, cb

        # zip text files and set headers
        (buf, cb) ->
          if  /\.(css|js)$/.test file
            zlib.gzip buf, (err, zip) ->
              return cb new Error "Error zipping #{file}" if err
              cb null, zip, {'Content-Encoding': 'gzip'}

          else
            cb null, buf, {}

        # put file to s3
        (buf, headers, cb) =>

          _(headers).extend
            'Expires'       : expireDate
            'Content-Type'  : mime.lookup file
            'Content-Length': buf.length

          @client.headFile filename, (err, res) =>
            return cb err if err
            md5 = '"' + crypto.createHash('md5').update(buf).digest('hex') + '"'
            if md5 is res.headers.etag
              logger.debug "[skip]    #{filename}"
              return cb null
            else if res.headers.etag
              logger.debug "[UPDATE]  #{filename}"
            else
              logger.debug "[ADD]     #{filename}"

            req  = @client.put filename, headers
            req.on 'response', (res) -> cb res.statusCode isnt 200
            req.end(buf)
      ], cb
