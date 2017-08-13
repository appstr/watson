class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @matches = []
    @top_answer = TopAnswer.where(user_id: current_user[:id]).first
    if !@top_answer.nil?
      answer_matches = TopAnswer.where("user_id != ?", current_user[:id])
                 .where(top_emotional_tone: @top_answer[:top_emotional_tone],
                        top_language_tone: @top_answer[:top_language_tone],
                        top_social_tone: @top_answer[:top_social_tone]
                        )
      if !answer_matches.blank?
        user_ids = []
        answer_matches.each{|answer| user_ids << answer[:user_id]}
        user_ids.each{|uid| @matches << User.find(uid)}
      end
    end
  end

end
