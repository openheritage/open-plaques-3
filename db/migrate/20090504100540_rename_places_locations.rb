class RenamePlacesLocations < ActiveRecord::Migration
  def self.up
    rename_table :places, :locations
    rename_column :plaques, :place_id, :location_id
    rename_column :personal_connections, :place_id, :location_id
    rename_column :areas, :places_count, :locations_count
  end

  def self.down
    rename_column :areas, :locations_count, :places_count
    rename_column :personal_connections, :location_id, :place_id
    rename_column :plaques, :location_id, :place_id
    rename_table :locations, :places
  end
end
