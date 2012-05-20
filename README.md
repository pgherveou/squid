Squid
=====

squid is a toolbox to build your node projects.
Squid take cares of the compilation of your coffee, jade and stylus files. You put all your files inside your
src folder and it will compile them to the output directory as soon as it detect a file change. It use growl to notify
you when a compilation failed or succeeded


Squid also export a publisher class to let you publish your file to amazon s3. You can control what files you want to publish
and squid will only upload new or updated files (see example below)

Squid 


executables
-----------

squid provide two executable commands,

<table>
  <tr>
    <th>binary</th><th>desc</th>
  </tr>
  <tr>
    <td>sb</td><td>build your project src folder</td>
  </tr>
  <tr>
    <td>sq</td><td>build your project, run your main script (node index.js) watch changes, auto-restart your app when changes are made to files in **/lib**</td>
  </tr>
</table>

Squid use growl to notify after each compilation
If you want to enable growl notification, install [growl] [1] and [growlNotify] [2]

Supported files for compilation
-------------------------------

squid can work with the following files

<table>
  <tr>
    <th>file</th><th>operation</th><th>note</th>
  </tr>
  <tr>
    <td>*.js</td><td>copy</td><td></td>
  </tr>
  <tr>
    <td>*.coffee</td><td>compile to js</td><td>files are compiled with bare option</td>
  </tr>
  <tr>
    <td>*.styl</td><td>compile to css</td><td>nib is imported, and /public/images is added to the path</td>
  </tr>
  <tr>
    <td>*.jade</td><td>compile to js</td><td>template are wrapped in a define function with a dependency on jade runtime</td>
  </tr>
</table>

files Dependencies
-------------------

squid manage your file dependencies and only compile the necessary files.
when using **sq** binary it also reload the code based on file dependencies.
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


Example
-------

Here is an example of a coffee script using a jade template

**src/path/to/template.jade**

```
.media
  a.img: img(src=user.picture)
.bd
  .first= user.firstName
  .last= user.lastName

```

**src/path/to/view.coffee**

```javascript

define(require) ->

  template = require './template'
  user = pict: 'path/to/pict', firstname: 'Pierre', lastName: 'Herveou'

  console.log template {user}


```


Here is an example of cake task that let you publish your file to s3

```javascript

task 'publish', 'optimize and upload to s3', publish = (opts, cb = noop) ->

  # create s3 publisher
  publisher = new Publisher bucket: 'your bucket name',  key: 'xxx', secret: 'xxx'

  # define filter closure that will only select js png and css file
  filter = (f, stat) ->
    return true if stat.isDirectory() or /\.(js|png|css)$/.test f
    false

  # publish public dir to root of assets bucket
  publisher.publishDir {origin: 'public', dest: '', filter}, cb

```



[1]: http://growl.info/growlupdateavailable   "growl"
[2]: http://growl.info/downloads              "growlNotify"
