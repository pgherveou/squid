Squid
=====

squid is a toolbox to build your node projects.
Squid take cares of the compilation of your coffee, jade and stylus files. You put all your files inside your
src folder and it will compile them to the output directory as soon as it detect a file change. 


Install
-------

install the package globally to use the two commands provided by the project (see desc below)

```
$ npm install -g squid
```


sq command
----------

at the root of your project directory execute: 

```
$ sq
```
this will

- start your server
- recompile your files as soon as they change and emit a growl notification*
- restart your server when file change inside /lib
- you can also combine it to a tool like livereload to auto refresh your browser when a client file has been recompiled 

* If you want to enable growl notification, install [growl] [1] and [growlNotify] [2]

sb command
----------
if you just want to build the project source files. use the sb command 
at the root of your project directory execute:

```
$ sb
```

You can also require squid to build your project inside your own script

```coffee
{builder} = require 'squid'
task 'build', 'Build project', (opts) ->
  builder.buildAll opts.exceptFolders, (errors) ->
    if err
      console.error 'Error building the project'
      console.error "file: #{e.file} :\n #{e.toString()}" for e in errors
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
task 'publish', 'optimize and upload to s3', publish = (opts, cb = noop) ->

  # create s3 publisher
  publisher = new Publisher bucket: 'your bucket name',  key: 'xxx', secret: 'xxx'

  # define filter closure that will only select js, png, and css file
  filter = (f, stat) -> true if stat.isDirectory() or /\.(js|png|css)$/.test f

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
    <td>*.js</td><td> squid simply copy js from your src folder to the output folder</td><td></td>
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

project structure
-----------------

To work with squid a project should have the following file organisation
<pre>
./
|- index.js
|- lib
|- public
|- src
  |- lib
  |- public
</pre>


A sample project using coffee, stylus and jade should have the following organisation

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
|- lib
  |- server_file1.js
|- public
  |- js
    |- client_file1.js
    |- client_file1.tpl.js
  |- css
    |- file1.css
</pre>



[1]: http://growl.info/growlupdateavailable   "growl"
[2]: http://growl.info/downloads              "growlNotify"
