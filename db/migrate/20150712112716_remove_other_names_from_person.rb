class RemoveOtherNamesFromPerson < ActiveRecord::Migration
  def self.up
    remove_column :people, :other_names
  end

  def self.down
    add_column :people, :other_names, :string
  end
end
