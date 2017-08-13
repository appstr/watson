class Question < ApplicationRecord
  belongs_to :user

  QUESTIONS_ENUM = {
    1 => "If you are walking down the street and see a homeless person asking for change, what would you say to them?",
    2 => "If you were asked to give a short lecture about your thoughts on religion, what would you say?",
    3 => "Donald Trump has invited you to the White House to hear your opinion of him in person, what do you say to him?"
  }
end


# 1: Deepest condolences to the families & fellow officers of the VA State Police who died today. You're all among the best this nation produces. We must remember this truth: No matter our color, creed, religion or political party, we are ALL AMERICANS FIRST.
# 2: We will continue to follow developments in Charlottesville, and will provide whatever assistance is needed. We are ready, willing and able. Am in Bedminster for meetings & press conference on V.A. &amp; all that we have done, and are doing, to make it better-but Charlottesville sad!
# 3: After 200 days, rarely has any Administration achieved what we have achieved..not even close! Don't believe the Fake News Suppression Polls! The Fake News refuses to report the success of the first 6 months: S.C., surging economy & jobs,border & military security,ISIS & MS-13 etc.
