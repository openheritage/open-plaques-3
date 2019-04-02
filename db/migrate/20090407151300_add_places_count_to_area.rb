class AddPlacesCountToArea < ActiveRecord::Migration[4.2]
  def self.up
    add_column :areas, :places_count, :integer
  end

  def self.down
    remove_column :areas, :places_count
  end
end
