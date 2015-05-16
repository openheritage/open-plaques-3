class AddDescriptionToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :description, :text
  end
end
