class AddDescriptionToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :description, :text
  end

  def self.down
    remove_column :plaques, :description
  end
end
