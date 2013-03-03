path   = require 'path'
fs     = require 'fs'
mkdirp = require 'mkdirp'
async  = require 'async'

# dirty string startWith method
String::startsWith = (starts) ->
  return true if starts is ''
  return false unless starts
  return @length >= starts.length and @[...starts.length] is starts

# Default build Error
exports.BuildError = class BuildError extends Error

  name: 'Build Error'

  constructor: (@file, @error) ->

  toString: ->
    """
    Build Error file: #{@file}

    #{@error.toString()}

    --
    """

# Builder base class
exports.Builder = class Builder

  constructor: (@config) ->
    @deps = {} # dependcy hashs
    @srcDir  = path.resolve @config.src
    @outDir  = path.resolve @config.out

  buildPath: (source, outDir) =>
    ext      = @outExt or path.extname(source)
    fileName = path.basename(source, path.extname(source)) + @outExt
    fileDir  = path.dirname(source)

    relative = fileDir.substring @srcDir.length
    relative = relative[1..] if relative[0] is path.sep

    for mapping in @config.mappings
      if relative.startsWith mapping.from
        fileDir = fileDir.replace(mapping.from, mapping.to)
        break

    dir = outDir + fileDir.substring @srcDir.length
    path.join dir, fileName

  # if new, write code in file
  write: (newCode, src, cb) ->
    file = @buildPath src, @outDir
    fs.readFile file, 'utf8', (err, oldCode) =>
      return cb null, file, null if newCode is oldCode
      file = @buildPath src, @outDir
      mkdirp path.dirname(file), 0o0755, (err) =>
        return cb new BuildError(file, err) if err
        fs.writeFile file, newCode, (err) =>
          return cb new BuildError(file, err) if err
          @refreshScan file, oldCode, newCode
          cb null, file, newCode

  # delete source build file
  removeBuild: (source, cb) ->
    fs.unlink @buildPath(source), (err) -> cb err, source, ""

  # get imports directive in code
  getImports: (file, code) ->
    return [] unless @reg
    path.resolve(path.dirname(file), m[1]) + (if path.extname(m[1]) then '' else @fileExt) while m = @reg.exec(code)

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

