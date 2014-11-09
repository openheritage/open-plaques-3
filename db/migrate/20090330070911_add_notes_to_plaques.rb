class AddNotesToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :notes, :text
  end

  def self.down
    remove_column :plaques, :notes
  end
end
