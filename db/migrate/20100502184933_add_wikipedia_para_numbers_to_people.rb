class AddWikipediaParaNumbersToPeople < ActiveRecord::Migration[4.2]
  def self.up
    add_column :people, :wikipedia_paras, :string
  end

  def self.down
    remove_column :people, :wikipedia_paras
  end
end
