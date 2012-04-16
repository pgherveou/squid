path     = require 'path'
fs       = require 'fs'
mkdirp   = require 'mkdirp'
_        = require 'nimble'
logger   = require('./loggers').get 'util'

exports.BuildError = BuildError = (file, error) ->
  Error.call @
  @file = file
  @message  = error.toString()
  this.name = 'Build Error'

exports.Builder = class Builder

  constructor: (srcDir, buildDir) ->
    @srcDir   = path.resolve srcDir
    @buildDir = path.resolve buildDir

  # dependcy hashs
  deps: {}

  # get the build path for source
  buildPath: (source, ext='.js') ->
    fileName = path.basename(source, path.extname(source)) + ext
    dir      = @buildDir + path.dirname(source).substring @srcDir.length
    path.join dir, fileName

  # if new, write code in file
  write: (newCode, file, cb) ->
    fs.readFile file, 'utf8', (err, oldCode) =>
      return cb null, file, "identical #{file}" if newCode is oldCode
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
    path.resolve(path.dirname(file), m[1]) + (if path.extname(m[1]) then '' else @fileExt) while m = @reg.exec(code)

  # scan files and set dependencies
  scan: (file, code) ->
    @deps[file] ?= {imports: [], refreshs: []}
    @deps[file].imports = []

    @getImports(file, code).forEach (importFile) =>
      @deps[file].imports.push importFile
      @deps[importFile] ?= {imports: [], refreshs: []}
      # console.log "add #{file} to @deps[#{importFile}].refreshs condition #{~@deps[importFile].refreshs.indexOf file}"
      @deps[importFile].refreshs.push(file) unless ~@deps[importFile].refreshs.indexOf file

  # update imports and refreshs reference
  refreshScan: (file, oldCode, newCode) ->
    @getImports(file, oldCode).forEach (importFile) =>
      refreshs = @deps[importFile].refreshs
      delete refreshs[refreshs[indexOf file]]
    @scan(file, newCode)

  # build file
  build: (file, refresh, cb) ->
    # logger.debug "build #{file}"
    fs.readFile file, 'utf8', (err, code) =>
      return cb new BuildError file, err if err
      @scan file, code
      @_build file, code, refresh, cb

