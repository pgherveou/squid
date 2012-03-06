sq_tooling
============

sq_tooling provide two executable script, 

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


To work with sq_tooling a project should have the following file oranisation
<pre>
./
|- index.js
|- lib
|- public
|- src
  |- lib
  |- public
</pre>

The **src** folder is only required if you are using files that need to be compiled first.

sq_tooling can work with the following files

<table>
  <tr>
    <th>file</th><th>operation</th>
  </tr>
  <tr>
    <td>*.js</td><td>simply copy the file</td>
  </tr>
  <tr>
    <td>*.coffee</td><td>compile to js and copy</td>
  </tr>
  <tr>
    <td>*.styl</td><td>compile to css and copy</td>
  </tr>
</table>

sq_tooling manage your file dependencies and only copy to the output the necessary files
here how you define dependencies for each supported file format

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
</table>



A sample project using .coffee files and stylus stylesheet should have the following organisation

<pre>
./
|- index.js
|- lib
|- public
|- src
  |- lib
    |- server_file1.coffee
    |- server_file2.coffee
    |- server_file3.coffee
  |- public
    |- js
      |- client_file1.coffee
      |- client_file2.coffee
      |- client_file3.coffee
    |- css
      |- file1.styl
      |- file2.styl
      |- file3.styl
</pre>
