class CreateLanguages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :alpha2
      t.integer :plaques_count
      t.timestamps

    end
  end

  def self.down
    drop_table :languages
  end
end
