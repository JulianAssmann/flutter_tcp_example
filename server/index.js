const net = require('net');

const hostname = 'localhost';
const port = 8000;

let currentSocket = null;

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout,
}).on('line', (input) => {
    if (currentSocket) {
        currentSocket.write(input);
        console.log(`Data sent to client: ${input}`);
    }
});

const server = net.createServer(async socket => {
    currentSocket = socket;
    socket.on('error', (err) => console.log('error', err));
    socket.on('data', (data) => console.log(`Data received from client: ${data}`));
    socket.on('close', (err) => {
        console.log('close', err)
        currentSocket = null;
    });

    // The following code counts up from 0 to infinity every second and sends the current counter value via TCP
    // try {
    //     console.log('Connected');
    //     let i = 0;
    //     while (socket.writable) {
    //         ++i;
    //         process.stdout.write(i.toString() + ', ');
    //         socket.write(i.toString());
    //         await new Promise(function (resolve, reject) {
    //             setTimeout(() => {
    //                 resolve();
    //             }, 1000)
    //         });
    //     }
    // } catch (err) {
    //     console.log(err);
    // }
});

server.listen(port, hostname);