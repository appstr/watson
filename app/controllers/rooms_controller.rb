class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    other_user = User.find(params[:id])
    title = [other_user.id.to_s, current_user.id.to_s].sort!.join("-")
    @room = Room.where(title: title).first
    if @room.nil?
      @room = Room.create! title: title
    else
      @messages = Message.where(room_id: @room[:id])
    end
  end

end
