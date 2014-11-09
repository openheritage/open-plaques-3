class AddLatLngAndSubjectToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :latitude, :string
    add_column :photos, :longitude, :string
    add_column :photos, :subject, :string
    add_column :photos, :description, :string
  end
end
