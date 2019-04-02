class AddCircaAttributesToPerson < ActiveRecord::Migration[4.2]
  def self.up
    add_column :people, :born_on_is_circa, :boolean
    add_column :people, :died_on_is_circa, :boolean
  end

  def self.down
    remove_column :people, :died_on_is_circa
    remove_column :people, :born_on_is_circa
  end
end
