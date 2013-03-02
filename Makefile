build:
	@coffee  -b --output "." --compile "src"

link: build
	@npm link