class AddDbpediaToColours < ActiveRecord::Migration[4.2]
  def self.up
    add_column :colours, :dbpedia_uri, :string
  end

  def self.down
    remove_column :colours, :dbpedia_uri
  end
end
