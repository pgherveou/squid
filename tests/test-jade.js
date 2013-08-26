var jade = require('jade');
if (jade.runtime) {jade = jade.runtime;}
module.exports = function (locals) {
  if (locals && jade.helpers) {(locals || (locals = {})).__proto__ = jade.helpers;}
  return function anonymous(locals) {
jade.debug = [{ lineno: 1, filename: "/Users/pg/OpenSource/squid/src/tests/test-jade.jade" }];
try {
var buf = [];
var locals_ = (locals || {}),bar = locals_.bar;jade.debug.unshift({ lineno: 1, filename: jade.debug[0].filename });
jade.debug.unshift({ lineno: undefined, filename: jade.debug[0].filename });
var foo_mixin = function(bar){
var block = this.block, attributes = this.attributes || {}, escaped = this.escaped || {};
jade.debug.unshift({ lineno: 2, filename: jade.debug[0].filename });
jade.debug.unshift({ lineno: 2, filename: jade.debug[0].filename });
buf.push("<div class=\"bar\">");
jade.debug.unshift({ lineno: undefined, filename: jade.debug[0].filename });
jade.debug.unshift({ lineno: 2, filename: jade.debug[0].filename });
buf.push("bar");
jade.debug.shift();
jade.debug.shift();
buf.push("</div>");
jade.debug.shift();
jade.debug.shift();
};
jade.debug.shift();
jade.debug.unshift({ lineno: 6, filename: jade.debug[0].filename });
jade.debug.shift();
jade.debug.unshift({ lineno: 6, filename: jade.debug[0].filename });
buf.push("<p>");
jade.debug.unshift({ lineno: undefined, filename: jade.debug[0].filename });
jade.debug.unshift({ lineno: 6, filename: jade.debug[0].filename });
buf.push("boooo");
jade.debug.shift();
jade.debug.shift();
buf.push("</p>");
jade.debug.shift();
jade.debug.unshift({ lineno: 7, filename: jade.debug[0].filename });
foo_mixin(bar);
jade.debug.shift();
jade.debug.shift();;return buf.join("");
} catch (err) {
  jade.rethrow(err, jade.debug[0].filename, jade.debug[0].lineno);
}
}.apply(this, arguments);
}