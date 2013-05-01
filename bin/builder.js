#!/usr/bin/env node
config = require('../lib/config');
if (process.env.DISABLE_POST_BUILD) config.post_build = {};

project = require('../lib/project');
project.buildAll();
