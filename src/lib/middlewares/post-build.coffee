{exec} = require 'child_process'

module.exports =

	init: (project) ->
		return unless project.config.post_build
		@reg = new RegExp config.post_build.match or ''
		@cmd = config.post_build.cmd
		@script = null
		project.onBuild @onBuild

	onBuild: (builder, newCode, src) =>
		return unless @reg.test(src)
	  @script?.kill()
	  @script = exec @cmd, (err, stdout, stderr) =>
	    console.log stdout + stderr
	    @script = null



