class AddUserIdToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :user_id, :integer
    add_column :users, :plaques_count, :integer
  end

  def self.down
    remove_column :users, :plaques_count
    remove_column :plaques, :user_id
  end
end
