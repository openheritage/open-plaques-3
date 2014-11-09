class ChangeLatLongToFloats < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

      # Postgres doesn't seem to like converting DB columns, so adding/removing them instead.

      remove_column :plaques, :latitude
      remove_column :plaques, :longitude

      add_column :plaques, :latitude, :float
      add_column :plaques, :longitude, :float

    else
      change_column :plaques, :latitude, :float, :null => true
      change_column :plaques, :longitude, :float, :null => true
    end
  end

  def self.down
  end
end
