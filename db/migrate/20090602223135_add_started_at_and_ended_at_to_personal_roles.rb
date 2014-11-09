class AddStartedAtAndEndedAtToPersonalRoles < ActiveRecord::Migration
  def self.up
    add_column :personal_roles, :started_at, :date
    add_column :personal_roles, :ended_at, :date
  end

  def self.down
    remove_column :personal_roles, :ended_at
    remove_column :personal_roles, :started_at
  end
end
