class RemovePlaqueErectedIdFromPlaques < ActiveRecord::Migration
  def change
    remove_column :plaques, :plaque_erected_year_id, :integer
  end
end
