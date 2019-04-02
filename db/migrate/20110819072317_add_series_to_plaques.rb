class AddSeriesToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :series_id, :integer
  end

  def self.down
    remove_column :plaques, :series_id
  end
end
