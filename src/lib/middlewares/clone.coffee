# clone output to different folders

module.exports =

	init: (project) ->
		return unless project.config.clone
		@clones = project.config.clone
		project.onBuild @onBuild

	onBuild: (builder, newCode, src, next) =>
	  @clones.forEach (clone) =>
	    if clone.match.test src
	      file = builder.buildPath src, path.resolve(clone.to)
	      file = file.replace map.from, map.to if map = clone.map
	      mkdirp path.dirname(file), 0o0755, (err) =>
	        return next("Error cloning dir to #{file}") if err
	        fs.writeFile file, newCode, (err) =>
	          return next("Error cloning dir to #{file}") if err
	          next()
