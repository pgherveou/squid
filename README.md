Squid
=====


Commands
-------

squid provide two executable commands,

<table>
  <tr>
    <th>binary</th><th>desc</th>
  </tr>
  <tr>
    <td>sb</td><td>build your project src folder</td>
  </tr>
  <tr>
    <td>sq</td><td>build your project, watch changes, restart when changes are made to /lib</td>
  </tr>
</table>

Squid use growl to notify after each compilation
If you want to enable growl notification, install [growl] [1] and [growlNotify] [2]

Supported files
---------------

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

Dependencies
------------

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


[1]: http://growl.info/growlupdateavailable   "growl"
[2]: http://growl.info/downloads              "growlNotify"
