class ChangePhotoDescriptionToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :photos, :description, :text
  end

  def self.down
    change_column :photos, :description, :string
  end
end
