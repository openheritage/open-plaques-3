class AddWikidataIdToRole < ActiveRecord::Migration[5.1]
  def change
    add_column :roles, :wikidata_id, :string
    remove_column :roles, :wikipedia_stub, :string
  end
end
