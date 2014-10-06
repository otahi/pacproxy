var dnode = require('dnode');
var pac   = require('pac-resolver');
var source;

process.on('uncaughtException', function(err){});

var server = dnode({
    find : function(source, uri, host, cb) {
        var FindProxyForURL = pac(source);
        FindProxyForURL(uri, host, function (err, res) {
            if (err) res = "DIRECT";
            cb(res);
        });
    }
});

var port = process.argv[2];
server.listen(port);
