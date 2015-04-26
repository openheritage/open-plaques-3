class AddPlaquesCountToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :plaques_count, :integer
    Area.connection.execute("update areas a set plaques_count = (select count(*) from plaques p where p.area_id = a.id)")
  end

  def self.down
    remove_column :areas, :plaques_count
  end
end
