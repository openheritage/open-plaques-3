class AddSlugIndexes < ActiveRecord::Migration
  def change
    add_index :organisations, :slug
    add_index :organisations, :name
  end
end
