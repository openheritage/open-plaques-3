class ChangePhotoDescriptionToText < ActiveRecord::Migration
  def self.up
    change_column :photos, :description, :text
  end

  def self.down
    change_column :photos, :description, :string
  end
end
