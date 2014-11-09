class AddAccurateGeolocationToPlaque < ActiveRecord::Migration
  def change
    add_column :plaques, :is_accurate_geolocation, :boolean, :default => true
	Plaque.where("accuracy = 'street' or accuracy = 'Street'").each do |f| 
	  f.update_attribute(:is_accurate_geolocation, 'false') 
	end
  end
end
