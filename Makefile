build :
				sudo npm update
				rm -r -f ./lib/*.js
				NODE_ENV=production cake build


.PHONY: build
