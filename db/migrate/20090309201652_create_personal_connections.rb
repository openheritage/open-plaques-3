class CreatePersonalConnections < ActiveRecord::Migration
  def self.up
    create_table :personal_connections do |t|
      t.integer :person_id, :verb_id, :place_id, :plaque_id
      t.timestamps
    end
  end

  def self.down
    drop_table :personal_connections
  end
end
