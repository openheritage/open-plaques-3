class AddTakenAtToPhotos < ActiveRecord::Migration[4.2]
  def self.up
    add_column :photos, :taken_at, :datetime
  end

  def self.down
    remove_column :photos, :taken_at
  end
end
