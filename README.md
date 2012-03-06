sq_tooling
============

sq_tooling provide an executable script, that will automatically build your files saved under **'./src'**
and restart your main script **'./index.js'** each time a file changed in **'./lib'**

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
sq_tooling performs the following operations

<table>
  <tr>
    <th>files</th><th>operation</th>
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
