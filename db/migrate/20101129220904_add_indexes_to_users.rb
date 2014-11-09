class AddIndexesToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
  end

  def self.down
  end
end
