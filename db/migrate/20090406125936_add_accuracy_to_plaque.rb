class AddAccuracyToPlaque < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :accuracy, :string
  end

  def self.down
    remove_column :plaques, :accuracy
  end
end
