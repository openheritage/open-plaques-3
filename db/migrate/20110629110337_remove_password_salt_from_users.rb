class RemovePasswordSaltFromUsers < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :users, :password_salt
  end

  def self.down
    add_column :users, :password_salt, :string,                            default: "",    null: false
  end
end
