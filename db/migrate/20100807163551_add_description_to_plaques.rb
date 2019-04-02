class AddDescriptionToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :description, :text
  end

  def self.down
    remove_column :plaques, :description
  end
end
