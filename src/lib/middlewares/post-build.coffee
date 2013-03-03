{exec} = require 'child_process'

module.exports = (project) ->
  {cmd, match} = project.config.post_build
  return unless cmd

  reg = new RegExp match or ''
  script = null

  project.on 'build', (src) ->
    return unless reg.test(src)
    script?.kill()
    script = exec cmd, (err, stdout, stderr) ->
      console.log stdout + stderr
      script = null



