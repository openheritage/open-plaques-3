class AddPlaquesCountToSeries < ActiveRecord::Migration[4.2]
  def change
    add_column :series, :plaques_count, :integer
    Series.connection.execute("update series set plaques_count = (select count(*) from plaques p where p.series_id = series.id)")
  end

  def self.down
    remove_column :series, :plaques_count
  end
end
