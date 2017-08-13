class CreateTopAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :top_answers do |t|
      t.belongs_to :user, index: true
      t.integer :top_emotional_tone
      t.integer :top_language_tone
      t.integer :top_social_tone
      t.timestamps
    end
  end
end
