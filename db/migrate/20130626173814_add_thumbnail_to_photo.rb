class AddThumbnailToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :thumbnail, :string
  end
end
