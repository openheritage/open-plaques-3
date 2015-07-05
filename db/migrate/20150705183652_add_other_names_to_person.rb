class AddOtherNamesToPerson < ActiveRecord::Migration
  def change
    add_column :people, :other_names, :string
  end
end
