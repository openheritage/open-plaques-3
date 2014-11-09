class AddDbpediaToColours < ActiveRecord::Migration
  def self.up
    add_column :colours, :dbpedia_uri, :string
  end

  def self.down
    remove_column :colours, :dbpedia_uri
  end
end
