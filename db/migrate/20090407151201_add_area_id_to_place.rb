class AddAreaIdToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :area_id, :integer
  end

  def self.down
    remove_column :places, :area_id
  end
end
