path     = require 'path'
fs       = require 'fs'
cs       = require 'coffee-script'
stylus   = require 'stylus'
mkdirp   = require 'mkdirp'
_        = require 'nimble'
nib      = require 'nib'

BuildError = (file, error) ->
  Error.call @
  @file = file
  @message ?= error.message ?= error
  this.name = 'Build Error'

class Builder

  # dependcy hashs
  deps: {}

  # get the build path for source
  buildPath: (source, ext='.js') ->
    fileName = path.basename(source, path.extname(source)) + ext
    dir      = SQ.dir.build + path.dirname(source).substring SQ.dir.src.length
    path.join dir, fileName

  # if new, write code in file
  write: (newCode, file, cb) ->
    fs.readFile file, 'utf8', (err, oldCode) =>
      return cb null, file, "identical" if newCode is oldCode
      mkdirp path.dirname(file), 0755, (err) =>
        return cb new BuildError file, err if err
        fs.writeFile file, newCode, (err) =>
          return cb new BuildError file, err if err
          cb null, file, "Compilation succeeded"
          @refreshScan file, oldCode, newCode

  # delete source build file
  removeBuild: (source, cb) ->
    fs.unlink @buildPath(source), (err) -> cb err, source, ""

  # get imports directive in code
  getImports: (file, code) ->
    path.resolve(path.dirname(file), m[1]) + @fileExt while m = @reg.exec(code)

  # scan files and set dependencies
  scan: (file, code) ->
    @deps[file] ?= {imports: [], refreshs: []}
    @deps[file].imports = []

    @getImports(file, code).forEach (importFile) =>
      @deps[file].imports.push importFile
      @deps[importFile] ?= {imports: [], refreshs: []}
      @deps[importFile].refreshs.push(file) unless ~@deps[importFile].refreshs.indexOf file

  # update imports and refreshs reference
  refreshScan: (file, oldCode, newCode) ->
    @getImports(file, oldCode).forEach (importFile) =>
      refreshs = @deps[importFile].refreshs
      delete refreshs[refreshs[indexOf file]]
    @scan(file, newCode)

  # build file
  build: (file, refresh, cb) ->
    fs.readFile file, 'utf8', (err, code) =>
      return cb new BuildError file, err if err
      @scan file, code
      @_build file, code, refresh, cb

###
coffee file builder
###
class CoffeeBuilder extends Builder

  fileExt: ".coffee"

  reg: /^#= import (.*)$/gm

  _build: (file, code, refresh, cb) ->
    if refresh and @deps[file].refreshs.length
      _.each @deps[file].refreshs,
        (f, cb) =>  @build f, refresh, cb
        (err) -> if err then cb new BuildError file, err else cb null
    else
      _.map @deps[file].imports,
        (importFile, cb) -> fs.readFile importFile, 'utf8', cb
        (err, imports) =>
          return  cb new BuildError file, err if err
          code = imports.join('\n') + code
          try
            js = cs.compile code, bare: true
            @write js, @buildPath(file), cb
          catch err
            cb new BuildError file, err

###
JS file builder
###
class JSBuilder extends Builder

  fileExt: ".js"

  reg: /^\/\/= import (.*)$/gm

  _build: (file, code, refresh, cb) ->
    if refresh and @deps[file].refreshs.length
      _.each @deps[file].refreshs,
        (f, cb) =>  @build f, refresh, cb
        (err) -> if err then cb new BuildError file, err else cb null
    else
      _.map @deps[file].imports,
        (importFile, cb) -> fs.readFile importFile, 'utf8', cb
        (err, imports) =>
          return cb new BuildError file, err if err
          code += imports.join '\n'
          @write code, @buildPath(file), cb

###
Stylus preprocessor builder
###
class StylusBuilder extends Builder

  reg: /^@import "(.*)"$/gm

  fileExt: ".styl"

  _build: (file, code, refresh, cb) ->

    @_compile file, code, (err, css) =>
      return cb new BuildError(file, err) if err

      if @deps[file].refreshs.length is 0
        @write css, @buildPath(file, '.css'), cb
      else if refresh
        _.each @deps[file].refreshs,
          (f, cb) =>
            @build f,refresh, cb
          (err) ->
            cb new BuildError(file, err) if err
            cb null, file, "Compilation succeeded"
      else
        cb null, file, "Compilation succeeded"


  _compile: (file, code, cb) ->
    stylus(code)
      .set('fileName', file)
      .set('paths', [SQ.dir.root, SQ.dir.img, SQ.dir.root + "/public/images", path.dirname file])
      .use(nib())
      .import('nib')
      .render cb

builders =
  '.coffee': new CoffeeBuilder
  '.js'    : new JSBuilder
  '.styl'  : new StylusBuilder
  get: (src) ->
    @[path.extname src]

exports.build = (src, cb) ->
  builders.get(src).build src, true, cb

exports.buildAll = (files, cb) ->
  _.reduce files,
    (memo, stat, file, cb) ->
      builder = builders.get(file)
      return cb null, memo unless builder
      builder.build file, false, (err) ->
        memo.push new BuildError(file, err) if err
        cb null, memo
    []
    (err, errors) ->
      if errors then cb errors else cb null


