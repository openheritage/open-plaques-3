class AddLatLonToSeries < ActiveRecord::Migration[4.2]
  def change
    add_column :series, :latitude, :float
    add_column :series, :longitude, :float
  end
end
