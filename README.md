sq_util
=======


files
-----

sq_util provide two executable scripts,

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

installation
------------

from the root folder of this project type

```
cake build
npm link
```

that will build the project and make **sq** and **sb** executable available in your global scope
you can then use these two commands to build and run your own project following the recommandations below


If you want to enable growl notification, install [growl] [1] and [growlNotify] [2]

Supported files
---------------

sq_tooling can work with the following files

<table>
  <tr>
    <th>file</th><th>operation</th>
  </tr>
  <tr>
    <td>*.js</td><td>copy</td>
  </tr>
  <tr>
    <td>*.coffee</td><td>compile to js</td>
  </tr>
  <tr>
    <td>*.styl</td><td>compile to css</td>
  </tr>
  <tr>
    <td>*.jade</td><td>compile to js</td>
  </tr>
</table>

Dependencies
------------


sq_util manage your file dependencies and only copy the necessary files.
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

To work with sq_util a project should have the following file organisation
<pre>
./
|- index.js
|- lib
|- public
|- src
  |- lib
  |- public
</pre>


A sample project using .coffee files and stylus stylesheet should have the following organisation

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
