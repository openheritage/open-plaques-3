class AddAddressIdxToPlaque < ActiveRecord::Migration
  def change
    add_index(:plaques, :area_id)
  end
end
