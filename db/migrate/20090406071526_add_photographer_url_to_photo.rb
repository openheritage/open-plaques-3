class AddPhotographerUrlToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :photographer_url, :string
  end

  def self.down
    remove_column :photos, :photographer_url
  end
end
