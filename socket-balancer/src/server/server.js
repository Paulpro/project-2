var io = require( 'socket.io' )( +process.argv[2] || 80 );

var os = require("os");
var hostname = os.hostname();

io.on('connection', function ( socket ) {

  socket.on('message', function ( message ) {

    var pos = message.indexOf( ':' );
    var id = message.substr(0, pos );
    var actual_message = message.substr( pos + 1 );

    console.log( 'Received: ' + actual_message );

    socket.send( id + ': Reply to (' + actual_message + ') from ' + hostname + ' @ ' + (new Date) );

  } );

  socket.on( 'disconnect', function ( ) {
    console.log( 'Disconnected' );
  } );
});
