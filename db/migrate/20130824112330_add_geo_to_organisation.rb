class AddGeoToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :latitude, :float
    add_column :organisations, :longitude, :float
  end
end
