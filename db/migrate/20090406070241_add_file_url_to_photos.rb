class AddFileUrlToPhotos < ActiveRecord::Migration
  def self.up
    # Delete all all photos first. We'll re-discover them later.
    #Photo.find(:all).each do |photo|
    #  photo.destroy
    #end
    add_column :photos, :file_url, :string
  end

  def self.down
    remove_column :photos, :file_url
  end
end
