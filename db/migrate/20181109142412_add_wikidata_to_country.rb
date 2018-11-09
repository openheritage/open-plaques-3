class AddWikidataToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :wikidata_id, :string
    remove_column :countries, :dbpedia_uri, :string
  end
end
