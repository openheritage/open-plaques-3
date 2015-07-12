class RemoveUserFromPlaque < ActiveRecord::Migration
  def self.up
    remove_column :plaques, :user_id
  end

  def self.down
    add_column :plaques, :user_id, :int
  end
end
