class AddAkaToPerson < ActiveRecord::Migration
  def change
    add_column :people, :aka, :text, array: true, default: []
  end
end
