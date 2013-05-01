#!/usr/bin/env node
config = require('../lib/config');
project = require('../lib/project');
if (process.env.DISABLE_POST_BUILD) config.post_build = {};
project.buildAll();
