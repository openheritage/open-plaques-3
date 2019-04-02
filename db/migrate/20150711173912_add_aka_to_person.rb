class AddAkaToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :aka, :text, array: true, default: []
  end
end
