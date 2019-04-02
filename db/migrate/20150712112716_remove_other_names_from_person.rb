class RemoveOtherNamesFromPerson < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :people, :other_names
  end

  def self.down
    add_column :people, :other_names, :string
  end
end
