class AddPrimaryRoleToPersonalRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :personal_roles, :primary, :boolean
  end
end
