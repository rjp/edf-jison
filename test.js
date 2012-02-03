var sys = require('util');
var fs = require('fs');
var p = require('./parser').parser;
function e(i) {
    sys.puts(i);
    return p.parse(i);
}

var test_string = fs.readFileSync(process.argv[2], 'utf8')

var x = e(test_string);
sys.puts(sys.inspect(x,true,8));
