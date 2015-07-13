class RemovePlaquesCountFromOrganisations < ActiveRecord::Migration
  def self.up
    remove_column :organisations, :plaques_count
  end

  def self.down
    add_column :organisations, :plaques_count, :int
  end
end
