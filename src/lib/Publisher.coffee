path   = require 'path'
fs     = require 'fs'
zlib   = require 'zlib'
crypto = require 'crypto'
knox   = require 'knox'
mime   = require 'mime'
async  = require 'async'
_      = require 'underscore'
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

      # set default filter
      filter or= -> true

      # convert origin folder to absolute
      origin = path.join path.resolve(origin)
      logger.info "uploading new files origin #{origin} to #{dest}"


      walk origin, filter, (err, fileItems) =>
        return logger.error err if err
        files = (file for file, stat of fileItems when stat.isFile())

        # create a task queue to upload file
        q = async.queue @publish, 10
        q.drain =  ->
          logger.debug "All files were uploaded"
          cb()

        files.forEach (file) =>
          filename = file.replace origin, dest
          #logger.info "upload #{file} to #{filename}"
          q.push {file, filename}, (err) ->
            return logger.debug "#{file} was uploaded" unless err
            cb err
            q.drain = ->

    publish: ({file, filename}, cb) =>

      logger.debug "publising #{file} to #{filename}"
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
            console.log  "compare #{md5} and #{res.headers.etag} => #{md5 is res.headers.etag}"
            return cb null, 'files are identical' if md5 is res.headers.etag

            req  = @client.put filename, headers
            req.on 'response', (res) ->
              console.log res.statusCode
              console.log req.url
              cb res.statusCode isnt 200
            req.end(buf)
      ], cb
