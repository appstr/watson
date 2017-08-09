class Tone < ApplicationRecord
  EMOTIONAL_ENUM = {
    1 => "anger",
    2 => "disgust",
    3 => "fear",
    4 => "joy",
    5 => "sadness"
  }

  LANGUAGE_ENUM = {
    1 => "analytical",
    2 => "confident",
    3 => "tentative"
  }

  SOCIAL_ENUM = {
    1 => "oppenness",
    2 => "conscientiousness",
    3 => "extraversion",
    4 => "agreeableness",
    5 => "emotional_range"
  }
end
