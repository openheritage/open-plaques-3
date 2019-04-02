class AddCountryIdToLocations < ActiveRecord::Migration[4.2]
  def self.up
    add_column :locations, :country_id, :integer

#    say_with_time("Assigning country ids to locations") do
#      Location.all do |location|
#        if location.area && location.area.country
#          location.update_attributes(country_id: location.area.country_id)
#        end
#      end
#    end
  end

  def self.down
    remove_column :locations, :country_id
  end
end
