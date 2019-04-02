class AddDefaultZeroToPhotoCounterCacheOnPlaques < ActiveRecord::Migration[4.2]
  def self.up
    change_column :plaques, :photos_count, :integer, default: 0, null: false
  end

  def self.down
    #
  end
end
