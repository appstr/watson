class HomeController < ApplicationController
  def welcome
    return redirect_to users_path if user_signed_in?
  end
end
