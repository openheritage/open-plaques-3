class AddPhotosCountToPlaque < ActiveRecord::Migration
  def self.up
    add_column :plaques, :photos_count, :integer
  end

  def self.down
    remove_column :plaques, :photos_count
  end
end
