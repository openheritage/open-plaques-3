class AddNotesToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :notes, :text
  end

  def self.down
    remove_column :plaques, :notes
  end
end
