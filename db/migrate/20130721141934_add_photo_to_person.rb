class AddPhotoToPerson < ActiveRecord::Migration
  def change
    add_column :photos, :person_id, :integer
  end
end
