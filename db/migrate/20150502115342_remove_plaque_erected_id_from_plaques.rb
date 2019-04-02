class RemovePlaqueErectedIdFromPlaques < ActiveRecord::Migration[4.2]
  def change
    remove_column :plaques, :plaque_erected_year_id, :integer
  end
end
