var server = new (require( 'ws' ).Server)( { port: 8080 } );

server.on('connection', function( socket ) {

  socket.on('message', function( message ) {

    console.log( 'Received: ', message );
    socket.send( new Date + ': ' + message );
  });
});
