class RemovePlaquesCountFromOrganisations < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :organisations, :plaques_count
  end

  def self.down
    add_column :organisations, :plaques_count, :int
  end
end
