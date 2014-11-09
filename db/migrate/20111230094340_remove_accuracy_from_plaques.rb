class RemoveAccuracyFromPlaques < ActiveRecord::Migration
  def up
    remove_column :plaques, :accuracy
  end

  def down
    add_column :plaques, :accuracy, :string
  end
end
