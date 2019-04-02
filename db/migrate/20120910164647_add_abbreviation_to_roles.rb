class AddAbbreviationToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :abbreviation, :string

  end
end
