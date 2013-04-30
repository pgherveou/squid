jade = require('jade');
if (jade.runtime) {jade = jade.runtime;}
module.exports = function (locals) {
  if (locals && jade.helpers) {(locals || (locals = {})).__proto__ = jade.helpers;}
  return function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<h1>Hello ' + escape((interp = user.name) == null ? '' : interp) + '</h1>' + ((interp = jade.view('user_detail_view', user)) == null ? '' : interp) + '');
}
return buf.join("");
}.apply(this, arguments);
}