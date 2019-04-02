class AddAddressIdxToPlaque < ActiveRecord::Migration[4.2]
  def change
    add_index(:plaques, :area_id)
  end
end
