class CreateConnections < ActiveRecord::Migration[4.2]
  def self.up
    create_table :connections do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end
