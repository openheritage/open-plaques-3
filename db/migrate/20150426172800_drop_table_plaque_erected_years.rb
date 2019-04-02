class DropTablePlaqueErectedYears < ActiveRecord::Migration[4.2]
  def change
    drop_table :plaque_erected_years
  end
end
