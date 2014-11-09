class AddOrdinalToPersonalRole < ActiveRecord::Migration
  def change
    add_column :personal_roles, :ordinal, :integer
  end
end
