class AddOrdinalToPersonalRole < ActiveRecord::Migration[4.2]
  def change
    add_column :personal_roles, :ordinal, :integer
  end
end
