class RemoveWoeidFromAreas < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :areas, :woeid
  end

  def self.down
    add_column :areas, :woeid, :integer
  end
end
