fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

module.exports = (project) ->

  # only apply to project with component.json file
  return unless fs.existsSync path.join(project.config.out, 'component.json')

  project.on 'build', (src) ->
    # if project
    # test if require statments are in component.json
    # for each require path check if lib/<name> exist
    # repeat for lib/name
    #
    # if src
    # test if src is js or coffee
    # check if require are in local component.json
