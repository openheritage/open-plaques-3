class AddLatLonToSeries < ActiveRecord::Migration
  def change
    add_column :series, :latitude, :float
    add_column :series, :longitude, :float
  end
end
