class AddWikipediaUrlAndDbpediaUriToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :wikipedia_url, :string
    add_column :people, :dbpedia_uri, :string
  end

  def self.down
    remove_column :people, :dbpedia_uri
    remove_column :people, :wikipedia_url
  end
end
