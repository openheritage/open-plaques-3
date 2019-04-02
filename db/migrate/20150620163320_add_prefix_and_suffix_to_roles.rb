class AddPrefixAndSuffixToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :prefix, :string
    add_column :roles, :suffix, :string
  end
end
