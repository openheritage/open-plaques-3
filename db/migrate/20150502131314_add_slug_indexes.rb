class AddSlugIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :organisations, :slug
    add_index :organisations, :name
  end
end
