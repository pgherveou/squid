Squid
=====

Squid compiles your coffee, jade and stylus files, and publish  your assets to amazon s3


Install
-------

install the package globally to use the commands provided by the project (see desc below)

```
$ npm install -g squid
```

sq command
----------

at the root of your project directory execute:

```
$ sq
```

or if your main script isn't index.js

```
$ sq my-script.js
```

to start node in debug mode

```
$ sq -d
```

this will

- start your server script
- live recompile your files and emit a growl notification**
- restart your server when a file change inside /lib (server script directory by convention)

You can also combine it to a tool like [liveReload] [1] to auto refresh your browser when client files are updated


**If you want to enable growl notification, install [growl] [2] and [growlNotify] [3]

![growl screenshot](https://github.com/pgherveou/squid/raw/gh-pages/images/growl.screenshot.png)


sb command
----------
if you just want to build the project source files. use the sb command
at the root of your project directory execute:

```
$ sb
```

You can also use squid to build your project inside your own build script

```coffee
{builder} = require 'squid'

# build all files in src except your css folder
builder.buildAll except: ['css'], (errs) ->
  if errs
    console.error 'Error building the project'
    console.error "#{e.file}: #{e.toString()}" for e in errs
  else
    console.log 'build sucessful!'
```

s3 publication
--------------

Squid publisher let you upload files within a directory to your amazon s3 bucket.
squid will only upload  new or modified files to your bucket.
squid will upload files with a far expiry date and will zip text files

```coffee
{Publisher} = require 'squid'

# create s3 publisher
publisher = new Publisher bucket: 'name',  key: 'xx', secret: 'xx'

# define filter closure that will only select js, png, and css file
filter = (f, stat) -> stat.isDirectory() or /\.(js|png|css)$/.test f

# publish 'public' dir to root folder '' of the  bucket
publisher.publishDir {origin: 'public', dest: '', filter}, cb

```


Supported files for compilation
-------------------------------

squid can compile the following files

<table>
  <tr>
    <th>file</th><th>operation</th><th>note</th>
  </tr>
  <tr>
    <td>*.js</td><td>copy</td><td>concat dependencies and copy to the output folder</td>
  </tr>
  <tr>
    <td>*.coffee</td><td>compile to js</td><td>files are compiled with bare option</td>
  </tr>
  <tr>
    <td>*.styl</td><td>compile to css</td><td>nib is imported, and /public/images is added to the path</td>
  </tr>
  <tr>
    <td>*.jade</td><td>compile to js</td><td>template are compiled into js and wrapped in a requirejs define function</td>
  </tr>
</table>

files Dependencies
-------------------

squid manage your file dependencies and only compile the necessary files.
here is how you define dependencies for each supported file format

<table>
  <tr>
    <th>file</th><th>import syntax</th>
  </tr>
  <tr>
    <td>*.js</td><td>//= import foo.js</td>
  </tr>
  <tr>
    <td>*.coffee</td><td>#= import foo.(coffee|js)</td>
  </tr>
  <tr>
    <td>*.styl</td><td>@import foo</td>
  </tr>
  <tr>
    <td>*.jade</td><td>include foo</td>
  </tr>
</table>

Configuration
-------------
You can define a squid.json object to specify src and build folder, and compilation options

```
// default options if you dont add a squid.json to your project
{
  "src": "src",
  "build": ".",
  "jade": {
    "amd": true
  },
  stylus: {
    url: ["public"],
    paths: ["public/images"]
  }
}
```

```

// custom squid.json configuration
// use mobile as root folder
// compile mobile/js/* to app/assets/javascripts/mobile
// compile mobile/stylesheets/* to app/assets/stylesheets/mobile
// config stylus to looup images in app/assets/images/mobile
// does not add amdWrap around jade templates

{
  "src": "mobile",
	"build": ".", 
	"mappings": [
		{"from": "js", "to": "app/assets/javascripts/mobile"},
		{"from": "stylesheets", "to": "app/assets/stylesheets/mobile"}
	],
	"stylus": {
		"paths": ["app/assets/images/mobile"],
		"url": ["app/assets/"]
	}, 
  "jade": {
    "amd": false
  }
}
```


project structure
-----------------

To work with squid, your project should follow this file architecture:

<pre>
./
|- index.js
|- src
  |- lib
    |- server_file1.coffee
  |- public
    |- js
      |- client_file1.coffee
      |- client_file1.tpl.jade
    |- css
      |- file1.styl
</pre>

after running **sb** or **sq**, this will generate the following files

<pre>
./
|- index.js
|- src
  |- ...
|- lib
  |- server_file1.js
|- public
  |- js
    |- client_file1.js
    |- client_file1.tpl.js
  |- css
    |- file1.css
</pre>


[1]: http://livereload.com/                                 "liveReload"
[2]: http://growl.info/growlupdateavailable                 "growl"
[3]: http://growl.info/downloads                            "growlNotify"
