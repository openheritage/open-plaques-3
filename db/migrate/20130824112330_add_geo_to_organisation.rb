class AddGeoToOrganisation < ActiveRecord::Migration[4.2]
  def change
    add_column :organisations, :latitude, :float
    add_column :organisations, :longitude, :float
  end
end
