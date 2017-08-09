class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.belongs_to :user, index: true
      t.integer :question_id
      t.string :response
      t.integer :emotional_tone_1
      t.integer :emotional_tone_2
      t.integer :language_tone_1
      t.integer :language_tone_2
      t.integer :social_tone_1
      t.integer :social_tone_2
      t.timestamps
    end
  end
end
