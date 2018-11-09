class AddPreferredZoomLevelToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :preferred_zoom_level, :int
  end
end
