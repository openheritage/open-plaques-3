class AddAbbreviationToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :abbreviation, :string

  end
end
