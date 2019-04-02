class AddDescriptionToCountry < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :description, :text
  end
end
