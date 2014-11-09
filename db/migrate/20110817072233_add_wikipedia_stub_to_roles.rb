class AddWikipediaStubToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :wikipedia_stub, :string
  end

  def self.down
    remove_column :roles, :wikipedia_stub
  end
end
