class AddOtherNamesToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :other_names, :string
  end
end
