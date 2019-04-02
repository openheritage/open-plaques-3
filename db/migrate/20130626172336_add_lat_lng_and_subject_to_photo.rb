class AddLatLngAndSubjectToPhoto < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :latitude, :string
    add_column :photos, :longitude, :string
    add_column :photos, :subject, :string
    add_column :photos, :description, :string
  end
end
