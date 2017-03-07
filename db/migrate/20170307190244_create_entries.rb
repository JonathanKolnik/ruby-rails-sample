class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.string :image_url
      t.string :name

      t.timestamps
    end
  end
end
