class CreatePages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :slug
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
