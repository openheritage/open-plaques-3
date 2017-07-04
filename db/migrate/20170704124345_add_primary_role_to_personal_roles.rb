class AddPrimaryRoleToPersonalRoles < ActiveRecord::Migration
  def change
    add_column :personal_roles, :primary, :boolean
  end
end
