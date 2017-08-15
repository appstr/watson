class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.belongs_to :user, index: true
      t.belongs_to :room, index: true
      t.string :content
      t.timestamps
    end
  end
end
