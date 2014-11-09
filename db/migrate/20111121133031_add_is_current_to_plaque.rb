class AddIsCurrentToPlaque < ActiveRecord::Migration
  def change
    add_column :plaques, :is_current, :boolean, :default => true
  end
end
