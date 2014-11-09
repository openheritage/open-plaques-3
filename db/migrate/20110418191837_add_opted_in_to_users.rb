class AddOptedInToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :opted_in, :boolean, :default => false
  end

  def self.down
    remove_column :users, :opted_in
  end
end
