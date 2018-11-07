class AddLatLonToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :latitude, :float
    add_column :countries, :longitude, :float
  end
end
