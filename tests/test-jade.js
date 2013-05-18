jade = require('jade');
if (jade.runtime) {jade = jade.runtime;}
module.exports = function (locals) {
  if (locals && jade.helpers) {(locals || (locals = {})).__proto__ = jade.helpers;}
  return function anonymous(locals) {
var buf = [];
with (locals || {}) {
var foo_mixin = function(bar){
var block = this.block, attributes = this.attributes || {}, escaped = this.escaped || {};
buf.push("<div class=\"bar\">bar</div>");
};
buf.push("<p>boooo</p>");
foo_mixin(bar);
}
return buf.join("");
}.apply(this, arguments);
}