class AddIsAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_admin, :boolean

    say_with_time("Making all existing users admin") do
      User.find_each do |user|
        user.make_admin
      end
    end
  end

  def self.down
    remove_column :users, :is_admin
  end
end
