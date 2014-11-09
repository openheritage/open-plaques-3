class AddUserIdToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :user_id, :integer
    add_column :users, :plaques_count, :integer

    say_with_time("Assigning a user id to plaques") do
      @user = User.find(:first)
      Plaque.find_each do |plaque|
        plaque.user = @user
        plaque.save
      end
    end
  end

  def self.down
    remove_column :users, :plaques_count
    remove_column :plaques, :user_id
  end
end
