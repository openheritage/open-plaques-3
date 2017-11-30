class RemoveWikipediaUrlFromPerson < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :wikipedia_url, :string
    remove_column :people, :wikipedia_paras, :string
    remove_column :people, :dbpedia_uri, :string
  end
end
