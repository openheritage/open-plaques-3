class RemoveLocationFromPersonalConnections < ActiveRecord::Migration[4.2]
  def change
    remove_reference :personal_connections, :location, index: true
    remove_column :countries, :locations_count
#    remove_column :countries, :plaques_count
    remove_column :areas, :locations_count
  end
end
