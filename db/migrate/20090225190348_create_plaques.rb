class CreatePlaques < ActiveRecord::Migration
  def self.up
    create_table :plaques do |t|
      t.date :erected_at
      t.string :latitude
      t.string :longtitude
      t.string :place_id
      t.timestamps
    end
  end

  def self.down
    drop_table :plaques
  end
end
