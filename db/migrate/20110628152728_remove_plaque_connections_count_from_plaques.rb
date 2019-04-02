class RemovePlaqueConnectionsCountFromPlaques < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :plaques, :plaque_connections_count
  end

  def self.down
    add_column :plaques, :plaque_connections_count, :integer
  end
end
