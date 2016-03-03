class RemovePlaquesCountFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :plaques_count
  end

  def self.down
    add_column :users, :plaques_count, :integer
  end
end
