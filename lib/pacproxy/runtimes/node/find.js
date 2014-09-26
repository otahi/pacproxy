var dnode = require('dnode');
var pac   = require('pac-resolver');
var source;

var socket = process.argv[2];
var server = dnode({
    find : function(source, uri, host, cb) {
        var FindProxyForURL = pac(source);
        FindProxyForURL(uri, host, function (err, res) {
            if (err) res = "DIRECT";
            cb(res);
        });
    }
});

server.listen(socket);
