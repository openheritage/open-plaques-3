class AddStartAndEndDatesToPersonalConnection < ActiveRecord::Migration[4.2]
  def self.up
    add_column :personal_connections, :started_at, :datetime
    add_column :personal_connections, :ended_at, :datetime
  end

  def self.down
    remove_column :personal_connections, :ended_at
    remove_column :personal_connections, :started_at
  end
end
