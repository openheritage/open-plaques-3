class RemoveUserFromPhotos < ActiveRecord::Migration[4.2]
  def change
    remove_reference :photos, :user, index: true
  end
end
