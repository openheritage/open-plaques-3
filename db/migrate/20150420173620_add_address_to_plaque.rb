class AddAddressToPlaque < ActiveRecord::Migration
  def change
    add_column :plaques, :address, :string
    add_column :plaques, :area_id, :integer
#    say_with_time("Setting addresses for existing plaques") do
#      Plaque.all.each do |p|
#        p.address = p.location.full_address if p.location
#        p.area_id = p.location.area_id if p.location && p.location.area
#        p.save
#      end
#    end
  end
end
