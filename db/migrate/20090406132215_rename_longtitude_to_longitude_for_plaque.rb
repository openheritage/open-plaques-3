class RenameLongtitudeToLongitudeForPlaque < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :plaques, :longtitude, :longitude
  end

  def self.down
    rename_column :plaques, :longitude, :longtitude
  end
end
