class AddWikipediaParaNumbersToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :wikipedia_paras, :string
  end

  def self.down
    remove_column :people, :wikipedia_paras
  end
end
