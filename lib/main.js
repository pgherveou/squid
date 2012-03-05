(function() {
  var Monitor, argv, buildReady, builder, codeChange, fs, hrLog, hrLogId, killApp, libMonitor, moment, path, relativeName, restart, server, serverScript, spawn, srcMonitor, srvArgs, start, startTime, writeStderr, writeStdout;

  require("./loggers");

  fs = require('fs');

  path = require('path');

  argv = require('optimist').alias('d', 'debug').argv;

  spawn = require('child_process').spawn;

  moment = require('moment');

  builder = require("./builder");

  Monitor = require("./finder").Monitor;

  serverScript = argv._[0] || 'index.js';

  server = null;

  startTime = null;

  buildReady = false;

  /*
  add an horizontal line after each log to make the log easier to read
  */

  hrLogId = null;

  hrLog = function() {
    var hr, i;
    hr = '';
    for (i = 1; i <= 50; i++) {
      hr += '.';
    }
    console.log(hr);
    console.log(moment().format('h:mm:ss - ddd MMM YY'));
    return console.log(hr);
  };

  writeStdout = function(data) {
    process.stdout.write(data);
    clearTimeout(hrLogId);
    return hrLogId = setTimeout(hrLog, 3000);
  };

  writeStderr = function(data) {
    process.stderr.write(data);
    clearTimeout(hrLogId);
    return hrLogId = setTimeout(hrLog, 3000);
  };

  /*
  Server stuffs
  */

  srvArgs = [];

  if (argv.debug) srvArgs.push('--debug');

  srvArgs.push(serverScript);

  start = function(msg) {
    if (msg == null) msg = 'Starting';
    if (!(buildReady && debuggerReady)) return;
    notifier.info(msg, {
      title: 'Server'
    });
    startTime = moment();
    spawn('node', srvArgs);
    server('exit', function(err) {
      if (!err) return;
      notifierror('Server down', {
        title: 'Server'
      });
      return restart();
    });
    server.stdout.on('data', writeStdout);
    return server.stderr.on('data', writeStderr);
  };

  restart = function() {
    server.kill('SIGHUP');
    if (!(moment().diff(startTime, 'seconds') < 2)) return start('Restarting');
  };

  /*
  builder stuffs
  */

  console.log("srcMonitor at " + (path.resolve('src')));

  console.log("libMonitor at " + (path.resolve('lib')));

  srcMonitor = new Monitor('src', path.join(__dirname, 'src'));

  libMonitor = new Monitor('lib', path.join(__dirname, 'lib'));

  relativeName = function(file) {
    return file != null ? file.substring(__dirname.length) : void 0;
  };

  srcMonitor.once('started', function(files) {
    notifier.debug("Watching " + srcMonitor.name, {
      title: srcMonitor.name
    });
    return builder.buildAll(files, function(errors) {
      var e, _i, _len, _results;
      if (errors.length) {
        _results = [];
        for (_i = 0, _len = errors.length; _i < _len; _i++) {
          e = errors[_i];
          _results.push(notifier.error(e.message, {
            title: relativeName(e.file)
          }));
        }
        return _results;
      } else {
        notifier.debug('Build done.', {
          title: srcMonitor.name
        });
        if (srcMonitor === serversrcMonitor) {
          buildReady = true;
          return start();
        }
      }
    });
  });

  codeChange = function(err, file, message) {
    if (err) {
      return notifier.error(err.message, {
        title: relativeName(err.file)
      });
    }
    return notifier.info(message, {
      title: relativeName(file)
    });
  };

  srcMonitor.on('created', function(f) {
    return builder.build(f, codeChange);
  });

  srcMonitor.on('changed', function(f) {
    return builder.build(f, codeChange);
  });

  srcMonitor.on('removed', function(f) {
    return builder.destroy(f, codeChange);
  });

  srcMonitor.once('stopped', function() {
    return notifier.info('Stop monitor', {
      title: srcMonitor.name
    });
  });

  srcMonitor.start();

  libMonitor.on('changed', restart);

  libMonitor.once('stopped', function() {
    return notifier.info('Stop monitor', {
      title: libMonitor.name
    });
  });

  libMonitor.start();

  /*
  process stuff
  */

  start();

  killApp = function(code) {
    if (code == null) code = 0;
    if (code) notifier.error('Killing server...');
    if (srcMonitor != null) srcMonitor.stop();
    if (libMonitor != null) libMonitor.stop();
    if (server) server.kill(code);
    return process.exit(code);
  };

  process.on('SIGINT', killApp);

  process.on('uncaughtException', function(err) {
    notifier.error("Caught exception: " + err, err);
    return killApp(1);
  });

}).call(this);
