var fs  = require('fs');
var pac = require('pac-resolver');

var pacFile = process.argv[2]
var uri     = process.argv[3]
var host    = process.argv[4]

var FindProxyForURL = pac(fs.readFileSync(pacFile, 'utf8'));

FindProxyForURL(uri, host, function (err, res) {
  if (err) throw err;
  console.log(res);
});
