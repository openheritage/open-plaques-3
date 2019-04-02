class AddShotToPhotos < ActiveRecord::Migration[4.2]
  def self.up
    add_column :photos, :shot, :string
  end

  def self.down
    remove_column :photos, :shot
  end
end
