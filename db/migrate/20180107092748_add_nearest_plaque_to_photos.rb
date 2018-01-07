class AddNearestPlaqueToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :nearest_plaque_id, :integer
    add_column :photos, :distance_to_nearest_plaque, :integer
  end
end
