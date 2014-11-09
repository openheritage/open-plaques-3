class AddReferenceToPlaque < ActiveRecord::Migration
  def self.up
    add_column :plaques, :reference, :string
  end

  def self.down
    remove_column :plaques, :reference
  end
end
