class AddPlacesCountToArea < ActiveRecord::Migration
  def self.up
    add_column :areas, :places_count, :integer
  end

  def self.down
    remove_column :areas, :places_count
  end
end
