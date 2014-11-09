class CreateTodoItems < ActiveRecord::Migration
  def self.up
    create_table :todo_items do |t|
	  t.string :description
	  t.string :action
	  t.string :url
	  t.string :image_url
	  t.integer :plaque_id
	  t.integer :user_id
	  t.timestamps
	end
  end

  def self.down
    drop_table :todo_items
  end
end