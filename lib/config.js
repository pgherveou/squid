// Generated by CoffeeScript 1.6.3
var builders, config, fileConfig, fs, path, _;

fs = require('fs');

_ = require('lodash');

path = require('path');

builders = require('./builders');

config = {
  src: 'src',
  out: '.',
  server: {
    script: 'index.js',
    env: {}
  },
  clone: [],
  mappings: [],
  builders: {
    js: {},
    json: {},
    coffee: {},
    css: {},
    handlebars: {
      wrap: 'commonJS'
    },
    jade: {
      wrap: 'commonJS'
    },
    stylus: {
      url: {
        paths: ['public']
      },
      paths: ['public/images']
    }
  },
  post_build: {
    match: '',
    cmd: ''
  }
};

if (fs.existsSync('squid.json')) {
  fileConfig = JSON.parse(fs.readFileSync('squid.json'));
  config = _.defaults(fileConfig, config);
}

module.exports = config;
