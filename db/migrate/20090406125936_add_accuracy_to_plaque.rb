class AddAccuracyToPlaque < ActiveRecord::Migration
  def self.up
    add_column :plaques, :accuracy, :string
  end

  def self.down
    remove_column :plaques, :accuracy
  end
end
