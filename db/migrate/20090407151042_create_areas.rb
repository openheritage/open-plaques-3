class CreateAreas < ActiveRecord::Migration[4.2]
  def self.up
    create_table :areas do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :areas
  end
end
