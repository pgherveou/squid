#!/usr/bin/env node
config = require('../lib/config');
if (process.env.DISABLE_POST_BUILD) config.post_build = {};

require('../lib/watch');

