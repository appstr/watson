$(document).ready ->
  room_id = $('#room_id').val()
  App.room = App.cable.subscriptions.create {channel: "RoomChannel", room_id: room_id},

    connected: ->
      # Called when the subscription is ready for use on the server

    disconnected: ->
      # Called when the subscription has been terminated by the server

    received: (data) ->
      $('#messages').append data['message']
      # Called when there's incoming data on the websocket for this channel

    speak: (message, room_id, user_id) ->
      @perform 'speak', message: message, room_id: room_id, user_id: user_id

$(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
  if event.keyCode is 13 # return = send
    App.room.speak event.target.value, $('#room_id').val(), $('#user_id').val()
    event.target.value = ""
    event.preventDefault()
