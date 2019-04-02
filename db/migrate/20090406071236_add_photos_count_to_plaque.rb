class AddPhotosCountToPlaque < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :photos_count, :integer
  end

  def self.down
    remove_column :plaques, :photos_count
  end
end
