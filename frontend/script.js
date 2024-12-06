// Establish socket connection
const socket = io('http://localhost:3000')

// Check which page we're on
const isIndexPage = document.getElementById('usernamePage') !== null
const isBuzzerPage = document.getElementById('buzzerPage') !== null
const isAdminPage = document.getElementById('adminPage') !== null

// Handle username submission on index page
if (isIndexPage) {
  document
    .getElementById('submitUsername')
    .addEventListener('click', function () {
      const username = document.getElementById('usernameInput').value.trim()
      const isAdmin = document.getElementById('adminCheck').checked

      if (username) {
        localStorage.setItem('username', username)
        localStorage.setItem('isAdmin', isAdmin)

        // Emit username to server and wait for validation
        socket.emit('setUsername', username)
      }
    })

  // Listen for duplicate username alert
  socket.on('duplicateUsername', () => {
    alert(
      'Dieser Benutzername ist bereits vergeben. Bitte wählen Sie einen anderen.'
    )
    localStorage.removeItem('username')
    localStorage.removeItem('isAdmin')
  })

  // Handle successful username validation
  socket.on('userListUpdate', () => {
    const isAdmin = localStorage.getItem('isAdmin') === 'true'
    if (isAdmin) {
      window.location.href = 'admin.html'
    } else {
      window.location.href = 'buzzer.html'
    }
  })
}

// Setup socket connection on buzzer page
if (isBuzzerPage) {
  const username = localStorage.getItem('username')
  if (!username) {
    window.location.href = 'index.html'
  } else {
    document.getElementById('usernameDisplay').textContent = username
    socket.emit('setUsername', username)

    const redButton = document.getElementById('redButton')

    // Handle buzzer button click
    redButton.addEventListener('click', function () {
      socket.emit('buzzerPressed')
      if (redButton.disabled) {
        redButton.style.transform = 'scale(0.95)'
        setTimeout(() => {
          redButton.style.transform = ''
        }, 100)
      }
    })

    // Handle buzzer lock state
    socket.on('buzzerLocked', (lockedBy) => {
      redButton.classList.add('locked')
      redButton.style.backgroundColor = '#999'
      redButton.style.cursor = 'pointer'
      redButton.style.boxShadow = 'none'
      redButton.style.border = '8px solid #666'
      redButton.style.opacity = '0.6'
    })

    // Handle buzzer reset state
    socket.on('buzzersReset', () => {
      redButton.classList.remove('locked')
      redButton.style.backgroundColor = ''
      redButton.style.cursor = 'pointer'
      redButton.style.boxShadow = ''
      redButton.style.border = ''
      redButton.style.opacity = '1'
    })

    // Handle buzzer state updates
    socket.on('buzzerState', ({ buzzerLocked }) => {
      if (buzzerLocked) {
        redButton.classList.add('locked')
        redButton.style.backgroundColor = '#999'
        redButton.style.cursor = 'pointer'
        redButton.style.boxShadow = 'none'
        redButton.style.border = '8px solid #666'
        redButton.style.opacity = '0.6'
      } else {
        redButton.classList.remove('locked')
        redButton.style.backgroundColor = ''
        redButton.style.cursor = 'pointer'
        redButton.style.boxShadow = ''
        redButton.style.border = ''
        redButton.style.opacity = '1'
      }
    })

    // Add message handling
    const messageSection = document.getElementById('messageSection')
    const messageInput = document.getElementById('messageInput')
    const sendButton = document.getElementById('sendMessage')
    const lastMessage = document.getElementById('lastMessage')

    // Handle chat state updates
    socket.on('chatStateUpdate', (enabled) => {
      messageSection.classList.toggle('disabled', !enabled)
      messageInput.disabled = !enabled
      sendButton.disabled = !enabled
    })

    // Handle buzzer state updates for chat
    socket.on('buzzerState', ({ chatEnabled }) => {
      messageSection.classList.toggle('disabled', !chatEnabled)
      messageInput.disabled = !chatEnabled
      sendButton.disabled = !chatEnabled
    })

    // Handle send button click
    sendButton.addEventListener('click', () => {
      const message = messageInput.value.trim()
      if (message) {
        socket.emit('sendMessage', message)
        lastMessage.textContent = `Letzte Nachricht: ${message}`
        messageInput.value = ''
      }
    })

    // Handle message input keypress
    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        const message = messageInput.value.trim()
        if (message) {
          socket.emit('sendMessage', message)
          lastMessage.textContent = `Letzte Nachricht: ${message}`
          messageInput.value = ''
        }
      }
    })
  }
}

// Setup admin features on admin page
if (isAdminPage) {
  const isAdmin = localStorage.getItem('isAdmin') === 'true'
  if (!isAdmin) {
    window.location.href = 'index.html'
  } else {
    const resetButton = document.getElementById('resetButton')
    const pressesList = document.getElementById('pressesList')
    const usersList = document.getElementById('usersList')
    const userMessages = document.getElementById('userMessages')
    const toggleChatButton = document.getElementById('toggleChat')

    // Update presses list
    function updatePressesList(presses) {
      pressesList.innerHTML = presses
        .map((press) => `<li>${press.username} (+${press.timeDiff}s)</li>`)
        .join('')
    }

    // Update users list
    function updateUsersList(users) {
      usersList.innerHTML = users.map((user) => `<li>${user}</li>`).join('')
    }

    // Handle reset button click
    resetButton.addEventListener('click', function () {
      socket.emit('resetBuzzers')
    })

    // Handle toggle chat button click
    toggleChatButton.addEventListener('click', () => {
      socket.emit('toggleChat')
    })

    // Handle buzzer lock state
    socket.on('buzzerLocked', (lockedBy) => {
      document.getElementById('winnerText').textContent = lockedBy
      resetButton.disabled = false
      pressesList.innerHTML = ''
    })

    // Handle subsequent presses
    socket.on('subsequentPress', ({ allPresses }) => {
      updatePressesList(allPresses)
    })

    // Handle buzzer reset state
    socket.on('buzzersReset', () => {
      document.getElementById('winnerText').textContent =
        'Warten auf Buzzer-Druck...'
      resetButton.disabled = true
      pressesList.innerHTML = ''
    })

    // Handle user list updates
    socket.on('userListUpdate', (users) => {
      updateUsersList(users)
    })

    // Handle message updates
    socket.on('messageUpdate', (messages) => {
      userMessages.innerHTML = messages
        .map(([username, { message, timestamp }]) =>
          message ? `<li><strong>${username}:</strong> ${message}</li>` : ''
        )
        .filter((msg) => msg)
        .join('')
    })

    // Handle chat state updates
    socket.on('chatStateUpdate', (enabled) => {
      toggleChatButton.textContent = enabled
        ? 'Chat deaktivieren'
        : 'Chat aktivieren'
      toggleChatButton.classList.toggle('enabled', enabled)
      toggleChatButton.classList.toggle('disabled', !enabled)
    })

    // Handle buzzer state updates
    socket.on(
      'buzzerState',
      ({
        buzzerLocked,
        firstPresser,
        subsequentPresses,
        connectedUsers,
        userMessages: messages,
        chatEnabled,
      }) => {
        if (buzzerLocked) {
          document.getElementById('winnerText').textContent = firstPresser
          resetButton.disabled = false
          updatePressesList(subsequentPresses)
        } else {
          document.getElementById('winnerText').textContent =
            'Warten auf Buzzer-Druck...'
          resetButton.disabled = true
          pressesList.innerHTML = ''
        }
        updateUsersList(connectedUsers)

        // Update messages
        if (messages) {
          userMessages.innerHTML = messages
            .map(([username, { message, timestamp }]) =>
              message ? `<li><strong>${username}:</strong> ${message}</li>` : ''
            )
            .filter((msg) => msg)
            .join('')
        }
      }
    )

    // Handle clear messages button click
    const clearMessagesButton = document.getElementById('clearMessages')

    clearMessagesButton.addEventListener('click', () => {
      // Clear only the admin's message display
      const userMessages = document.getElementById('userMessages')
      userMessages.innerHTML = ''
    })
  }
}
