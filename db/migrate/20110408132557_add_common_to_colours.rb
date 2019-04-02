class AddCommonToColours < ActiveRecord::Migration[4.2]
  def self.up
    add_column :colours, :common, :boolean, default: false, null: false
  end

  def self.down
    remove_column :colours, :common
  end
end
