class AddColourIdToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :colour_id, :integer
  end

  def self.down
    remove_column :plaques, :colour_id
  end
end
