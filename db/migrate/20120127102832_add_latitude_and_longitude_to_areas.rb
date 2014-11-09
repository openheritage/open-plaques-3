class AddLatitudeAndLongitudeToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :latitude, :float
    add_column :areas, :longitude, :float
  end
end
