class AddSeriesRefToPlaques < ActiveRecord::Migration
  def change
    add_column :plaques, :series_ref, :string
  end
end
