sq_tooling
============

sq tooling provide an executable script, that will automatically build your files saved under './src'
and restart your main script './index.js' each time a file changed in './lib'

To work with sq_tooling a project should have the following file oranisation

./
|- index.js
|- lib
|- public
|- src
  |- lib
  |- public

the src folder is optional and only required if you are using files that need to be compiled first
a sample project using .coffee files and stylus stylesheet should have the following organisation

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

