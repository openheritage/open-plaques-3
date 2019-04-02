class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :photos, :person_id
    add_index :plaques, :series_id
  end
end
