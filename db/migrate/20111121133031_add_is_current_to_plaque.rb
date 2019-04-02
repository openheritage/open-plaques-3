class AddIsCurrentToPlaque < ActiveRecord::Migration[4.2]
  def change
    add_column :plaques, :is_current, :boolean, default: true
  end
end
