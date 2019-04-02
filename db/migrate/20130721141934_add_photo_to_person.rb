class AddPhotoToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :person_id, :integer
  end
end
