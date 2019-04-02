class AddPhotographerUrlToPhoto < ActiveRecord::Migration[4.2]
  def self.up
    add_column :photos, :photographer_url, :string
  end

  def self.down
    remove_column :photos, :photographer_url
  end
end
