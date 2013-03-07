fs       = require 'fs'
_        = require 'lodash'
path     = require 'path'
builders = require './builders'

# default project config
config =
  src: 'src'
  out: '.'
  server:
    script: 'index.js'
    env: {}
  clone: []
  mappings: []
  builders:
    js: {}
    json: {}
    coffee: {}
    css: {}
    handlebars:
      wrap: 'commonJS'
    jade:
      wrap: 'commonJS'
    stylus:
      url: paths: ['public']
      paths: ['public/images']
  post_build: {match: '', cmd: '' }

# use squid.json config file if present
if fs.existsSync 'squid.json'
  fileConfig = JSON.parse(fs.readFileSync 'squid.json')
  config = _(fileConfig).defaults(config)

# module exports
module.exports = config