class AddOfAPlaqueToPhotos < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :of_a_plaque, :boolean, default: true
	  Photo.update_all ["of_a_plaque = ?", true]
  end
end
