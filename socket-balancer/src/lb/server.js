var io = require( 'socket.io' )( +process.argv[2] || 80 );

var config = require( './config.js' );

var SocketClient = require( 'socket.io-client' );

var clients = {};
for ( var i = 0; i < config.servers.length; i++ ) {

    var host = config.servers[i];

    var client = new SocketClient( 'ws://' + host.address );
    clients[ i ] = client;

    client.on( 'message', function ( message ) {
        var pos = message.indexOf( ':' );
        var id = message.substr(0, pos );
        io.sockets.to( id ).send( message.substr( pos + 1 ) );
    } );
}

var j = 0;
var num_clients = Object.keys( clients ).length;

io.on('connection', function ( socket ) {

  socket.on('message', function ( message ) {

    j = ( j + 1 ) % num_clients;
    clients[ j ].send( socket.id + ':' + message );
    
  } );

  socket.on( 'disconnect', function ( ) {
    console.log( 'Disconnected' );
  } );
});
