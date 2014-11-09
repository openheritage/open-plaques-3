class RenameLongtitudeToLongitudeForPlaque < ActiveRecord::Migration
  def self.up
    rename_column :plaques, :longtitude, :longitude
  end

  def self.down
    rename_column :plaques, :longitude, :longtitude
  end
end
