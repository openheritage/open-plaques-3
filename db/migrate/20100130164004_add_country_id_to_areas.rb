class AddCountryIdToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :country_id, :integer
  end

  def self.down
    remove_column :areas, :country_id
  end
end
