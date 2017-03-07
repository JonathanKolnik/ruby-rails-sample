class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.references :entry, foreign_key: true
      t.string :user

      t.timestamps
    end
  end
end
