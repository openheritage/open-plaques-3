class AddIndexToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :index, :string

    say_with_time("Setting index letter on roles") do
      Role.find_each do |role|
        role.index = role.name[0,1].downcase
        role.save!
      end
    end

  end

  def self.down
    remove_column :roles, :index
  end
end
