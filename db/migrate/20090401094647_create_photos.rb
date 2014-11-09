class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :user_id
      t.string :photographer
      t.string :url
      t.integer :plaque_id

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
