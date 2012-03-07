(function() {
  var Monitor, argv, buildReady, builder, codeChange, fs, hrLog, hrLogId, killApp, libMonitor, logger, moment, notifier, path, relativeName, restart, server, serverScript, spawn, srcMonitor, srvArgs, start, startTime, writeStderr, writeStdout;

  fs = require('fs');

  path = require('path');

  argv = require('optimist').alias('d', 'debug').argv;

  spawn = require('child_process').spawn;

  moment = require('moment');

  builder = require("./projectBuilder");

  Monitor = require("./finder").Monitor;

  logger = require('./loggers').get('util');

  notifier = require('./loggers').get('notifier');

  serverScript = argv._[0] || 'index.js';

  server = null;

  startTime = null;

  buildReady = false;

  /*
  add an horizontal line after each log to make it easier to read
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
    notifier.info(msg, {
      title: 'Server'
    });
    startTime = moment();
    logger.info("starting " + srvArgs);
    server = spawn('node', srvArgs);
    server.on('exit', function(err) {
      if (!err) return;
      notifier.error('Server down', {
        title: 'Server'
      });
      return restart();
    });
    server.stdout.on('data', writeStdout);
    return server.stderr.on('data', writeStderr);
  };

  restart = function() {
    if (!server) return;
    server.kill('SIGHUP');
    if (!(moment().diff(startTime, 'seconds') < 2)) return start('Restarting');
  };

  /*
  builder stuffs
  */

  srcMonitor = new Monitor('src Monitor', path.resolve('src'));

  libMonitor = new Monitor('lib Monitor', path.resolve('lib'));

  relativeName = function(file) {
    return file != null ? file.substring(__dirname.length) : void 0;
  };

  codeChange = function(err, file, message) {
    if (err) {
      return notifier.error(err.message, {
        title: relativeName(err.file)
      });
    }
    return notifier.info(message, {
      title: relativeName(file) || srcMonitor.name
    });
  };

  srcMonitor.on('created', function(f) {
    return builder.liveBuild(f, codeChange);
  });

  srcMonitor.on('changed', function(f) {
    return builder.liveBuild(f, codeChange);
  });

  srcMonitor.on('removed', function(f) {
    return builder.removeBuild(f, codeChange);
  });

  srcMonitor.once('stopped', function() {
    return notifier.info('Stop monitor', {
      title: srcMonitor.name
    });
  });

  srcMonitor.once('started', function(files) {
    notifier.debug("Watching", {
      title: srcMonitor.name
    });
    return builder.liveBuildAll(files, function(errors) {
      var e, _i, _len, _results;
      if (errors) {
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
        buildReady = true;
        return start();
      }
    });
  });

  srcMonitor.start();

  libMonitor.once('started', function(files) {
    return notifier.debug("Watching", {
      title: libMonitor.name
    });
  });

  libMonitor.on('changed', function() {
    if (buildReady) return restart();
  });

  libMonitor.on('created', function() {
    if (buildReady) return restart();
  });

  libMonitor.once('stopped', function() {
    return notifier.info('Stop monitor', {
      title: libMonitor.name
    });
  });

  libMonitor.start();

  /*
  process stuff
  */

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
