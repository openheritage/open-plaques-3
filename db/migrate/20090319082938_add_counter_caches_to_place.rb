class AddCounterCachesToPlace < ActiveRecord::Migration[4.2]
  def self.up
    add_column :places, :personal_connections_count, :integer
    add_column :places, :plaques_count, :integer
  end

  def self.down
    remove_column :places, :plaques_count
    remove_column :places, :personal_connections_count
  end
end
