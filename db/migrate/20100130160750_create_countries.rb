class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name
      t.string :alpha2
      t.integer :areas_count
      t.integer :plaques_count
      t.integer :locations_count
      t.string :dbpedia_uri

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
