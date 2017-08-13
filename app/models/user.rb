class User < ApplicationRecord
  has_many :questions
  has_one :top_answer
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.has_answers?(current_user_id)
    if Question.where(user_id: current_user_id).first.nil?
      return false
    else
      return true
    end
  end

end
