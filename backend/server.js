/**
 * Buzzer Game Server
 * 
 * Installation:
 * npm install
 * 
 * Start Server:
 * npm start
 * 
 * Server runs on: http://localhost:3000
 */

// Import necessary modules
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

// Initialize Express app and HTTP server
const app = express();
const server = http.createServer(app);

// Setup Socket.IO server with CORS configuration
const io = new Server(server, {
  cors: {
    origin: '*',
  }
});

// Define server port and initialize state variables
const port = 3000;
let buzzerLocked = false;
let firstPresser = null;
let firstPressTime = null;
let subsequentPresses = [];
let connectedUsers = new Map();
let userMessages = new Map();
let chatEnabled = false;

// Use CORS and JSON middleware
app.use(cors());
app.use(express.json());

// Handle new socket connections
io.on('connection', (socket) => {
  console.log('A user connected');

  // Emit initial buzzer state to the connected user
  socket.emit('buzzerState', { 
    buzzerLocked, 
    firstPresser,
    subsequentPresses,
    connectedUsers: Array.from(connectedUsers.values()),
    userMessages: Array.from(userMessages.entries()),
    chatEnabled
  });

  // Handle setting of username
  socket.on('setUsername', (username) => {
    if (Array.from(connectedUsers.values()).includes(username)) {
      socket.emit('duplicateUsername');
    } else {
      socket.username = username;
      connectedUsers.set(socket.id, username);
      userMessages.set(username, { message: '', timestamp: Date.now() });
      console.log(`Username set to: ${username}`);
      io.emit('userListUpdate', Array.from(connectedUsers.values()));
    }
  });

  // Handle chat toggle
  socket.on('toggleChat', () => {
    chatEnabled = !chatEnabled;
    io.emit('chatStateUpdate', chatEnabled);
  });

  // Handle sending of messages
  socket.on('sendMessage', (message) => {
    if (socket.username && chatEnabled) {
      userMessages.set(socket.username, { 
        message: message, 
        timestamp: Date.now() 
      });
      io.emit('messageUpdate', Array.from(userMessages.entries()));
    }
  });

  // Handle buzzer press events
  socket.on('buzzerPressed', () => {
    // Capture the current time when the buzzer is pressed
    const currentTime = Date.now();
    
    // Check if the buzzer is not locked
    if (!buzzerLocked) {
      // Lock the buzzer and record the first presser's username and press time
      buzzerLocked = true;
      firstPresser = socket.username;
      firstPressTime = currentTime;
      subsequentPresses = []; // Reset subsequent presses
      console.log(`${socket.username} pressed the buzzer first!`);
      
      // Notify all clients that the buzzer is now locked
      io.emit('buzzerLocked', socket.username);
    } else {
      // Check if the user has already pressed the buzzer after it was locked
      const alreadyPressed = subsequentPresses.some(press => press.username === socket.username);
      
      // If the user hasn't pressed yet, record their press time difference
      if (!alreadyPressed) {
        const timeDiff = ((currentTime - firstPressTime) / 1000).toFixed(3); // Calculate time difference in seconds
        subsequentPresses.push({
          username: socket.username,
          timeDiff: timeDiff
        });
        console.log(`${socket.username} pressed the buzzer after ${timeDiff} seconds`);
        
        // Notify all clients about the subsequent press and update the list of all presses
        io.emit('subsequentPress', {
          username: socket.username,
          timeDiff: timeDiff,
          allPresses: subsequentPresses
        });
      }
    }
  });

  // Handle buzzer reset
  socket.on('resetBuzzers', () => {
    buzzerLocked = false;
    firstPresser = null;
    firstPressTime = null;
    subsequentPresses = [];
    console.log('Buzzers have been reset');
    io.emit('buzzersReset');
  });

  // Handle user disconnection
  socket.on('disconnect', () => {
    if (connectedUsers.has(socket.id)) {
      const username = connectedUsers.get(socket.id);
      connectedUsers.delete(socket.id);
      userMessages.delete(username);
      io.emit('userListUpdate', Array.from(connectedUsers.values()));
      io.emit('messageUpdate', Array.from(userMessages.entries()));
    }
    console.log('User disconnected');
  });
});

// Start the server
server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});