# Squid

Squid is a command line tool that monitor changes in the file system and compiles your files automatically each time you save.
It supports coffeescript, stylus and Jade, but can easily be extended to other file types.

## Install

install the package globally to use the commands provided by the project (see desc below)

```
$ npm install -g squid
```

## sq command

at the root of your project directory execute:

```
$ sq
```

this will

- start your server script
- live recompile your files and emit a growl notification**
- auto-restart your node server when a file change inside /lib

You can also combine it to a tool like [liveReload] [1] to auto refresh your browser when client files are updated

**If you want to enable growl notification, install [growl] [2] and [growlNotify] [3]

![growl screenshot](https://github.com/pgherveou/squid/raw/gh-pages/images/growl.screenshot.png)

By default squid will relaunch index.js each time a change occurs in /lib if your main script isn't index.js
you can specify a different script

```
$ sq my-script.js
```

to launch node in debug mode use -d option

```
$ sq -d
```



## sb command

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

## Supported files for compilation

squid can compile the following files.
Want to add support for other file types? New builder can easily be implemented using the base Builder classe

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

## files Dependencies

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

## Configuration

You can define a squid.json object to specify folder mappings, and compilation options
Here are the default options if you dont add a squid.json to your project

```js
{
  "src": "src", /* source folder */
  "out": ".", /* build  folder */
  "jade": { /* jade default options */
    "amd": true /* wrap jade template inside a requirejs define block */
  },
  "stylus": { /* stylus default options */
    "url": {paths: ["public"]}, /* url options  */
    "paths": ["public/images"] /* image lookup path  */
  }
}
```
So if you have the following project
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

after running **sb** or **sq**, squid will generate the following files

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

### Optional configuration
If your project structure is different you can add a custom squid.json configuration:

#### mappings

You can define mappings rules to output your files into different folders

The following squid.json config
- use mobile as src folder
- compile mobile/js/* to app/assets/javascripts/mobile
- compile mobile/stylesheets/* to app/assets/stylesheets/mobile

```json
{
"src": "mobile",
"mappings": [
	{"from": "js", "to": "app/assets/javascripts/mobile"},
	{"from": "stylesheets", "to": "app/assets/stylesheets/mobile"}
]
}
```

### post build

You can specify a script to launch after each successful file build

The following squid.json config will trigger **make bundle-app**  each time a file is successfully
built in src/public

```json
{
  "post_build": {"match": "src/public", "cmd": "make bundle-app" }
}
```

### clone

You can specify multiple output folders for your build

The following squid.json config
- compile your files to the default output folder (project root)
- clones everything under src/public to phonegap/js

```json
{
  "clone": [
    { "match": "src/public", "to" : "phonegap/js"}
  ]
}
```


## s3 publication

Squid publisher let you upload files within a directory to your amazon s3 bucket.
- it only uploads new or modified files to your bucket.
- it sets a far expiry date and zip files

```coffee
{Publisher} = require 'squid'

# create s3 publisher
publisher = new Publisher bucket: 'name',  key: 'xx', secret: 'xx'

# define filter closure that will only select js, png, and css file
filter = (f, stat) -> stat.isDirectory() or /\.(js|png|css)$/.test f

# publish 'public' dir to root folder '' of the  bucket
publisher.publishDir {origin: 'public', dest: '', filter}, cb

```


## TODO

- Add more compiler options for compiler (PR are welcome)
- Write some tests !!!


[1]: http://livereload.com/                                 "liveReload"
[2]: http://growl.info/growlupdateavailable                 "growl"
[3]: http://growl.info/downloads                            "growlNotify"
