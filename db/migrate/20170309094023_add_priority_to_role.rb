class AddPriorityToRole < ActiveRecord::Migration
  def change
    add_column :roles, :priority, :integer
  end
end
