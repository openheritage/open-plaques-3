class AddWikipediaStubToRoles < ActiveRecord::Migration[4.2]
  def self.up
    add_column :roles, :wikipedia_stub, :string
  end

  def self.down
    remove_column :roles, :wikipedia_stub
  end
end
