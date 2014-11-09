class AddDeviseFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :encrypted_password, :string, :limit => 128, :null => false, :default => ""
    add_column :users, :password_salt, :string, :null => false, :default => ""
    add_column :users, :reset_password_token, :string
    add_column :users, :remember_created_at, :datetime
    add_column :users, :sign_in_count, :integer, :default => 0
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

  end

  def self.down
    remove_column :table_name, :column_name
    remove_column :table_name, :column_name
  end
end