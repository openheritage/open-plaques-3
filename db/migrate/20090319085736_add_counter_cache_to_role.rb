class AddCounterCacheToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :personal_roles_count, :integer

    say_with_time("Setting personal_roles_count counter on roles") do
      Role.find_each do |role|
        Role.update_counters(role.id, :personal_roles_count => Role.find(role.id).personal_roles.size)
      end
    end
  end

  def self.down
    remove_column :roles, :personal_roles_count
  end
end
