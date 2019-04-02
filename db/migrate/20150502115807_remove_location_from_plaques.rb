class RemoveLocationFromPlaques < ActiveRecord::Migration[4.2]
  def change
    remove_index :plaques, :location_id
    remove_column :plaques, :location_id
   end
end
