class AddWoeIdAndDbpediaUriToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :woeid, :integer
    add_column :areas, :dbpedia_uri, :string
  end

  def self.down
    remove_column :areas, :dbpedia_uri
    remove_column :areas, :woeid
  end
end
