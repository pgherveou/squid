build:
	@coffee  -b --output "." --compile "src"

clean:
	@rm -f -r lib/*

link: clean build
	@npm link