class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    m = Message.new
    m.user_id = data["user_id"]
    m.room_id = data["room_id"]
    m.content = data["message"]
    m.save!
  end
end
