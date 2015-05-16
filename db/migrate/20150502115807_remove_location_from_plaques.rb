class RemoveLocationFromPlaques < ActiveRecord::Migration
  def change
    remove_index :plaques, :location_id
    remove_column :plaques, :location_id
   end
end
