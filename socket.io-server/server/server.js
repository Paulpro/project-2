var io = require( 'socket.io' )( 8081 );

io.on( 'connection', function ( socket ) {

  socket.on( 'message', function ( message ) {
    console.log( 'Received: ', message );
  } );

  socket.on( 'disconnect', function ( ) {
    console.log( 'Disconnected' );
  } );

} );
