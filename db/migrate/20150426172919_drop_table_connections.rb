class DropTableConnections < ActiveRecord::Migration[4.2]
  def change
    drop_table :connections
  end
end
