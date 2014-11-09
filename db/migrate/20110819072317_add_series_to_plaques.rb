class AddSeriesToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :series_id, :integer
  end

  def self.down
    remove_column :plaques, :series_id
  end
end
