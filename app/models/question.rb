class Question < ApplicationRecord
  belongs_to :user

  QUESTIONS_ENUM = {
    1 => "If you are walking down the street and see a homeless person asking for change, what would you say to them?",
    2 => "If you were asked to give a short lecture about your thoughts on religion, what would you say?",
    3 => "Donald Trump has invited you to the White House to hear your opinion of him in person, what do you say to him?"
  }
end
