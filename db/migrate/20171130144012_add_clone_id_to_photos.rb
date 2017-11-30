class AddCloneIdToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :clone_id, :integer
  end
end
