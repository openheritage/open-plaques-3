class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :photos, :person_id
    add_index :plaques, :series_id
  end
end
