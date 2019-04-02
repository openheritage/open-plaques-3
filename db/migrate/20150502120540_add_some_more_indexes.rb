class AddSomeMoreIndexes < ActiveRecord::Migration[4.2]
  def change
    remove_index(:plaques, column: :personal_connections_count)
    add_index :areas, :slug
    add_index :areas, :name
  end
end
