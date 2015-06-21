class AddPrefixAndSuffixToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :prefix, :string
    add_column :roles, :suffix, :string
  end
end
