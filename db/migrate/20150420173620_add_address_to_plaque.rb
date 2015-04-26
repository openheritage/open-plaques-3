class AddAddressToPlaque < ActiveRecord::Migration
  def change
    add_column :plaques, :address, :string
    add_column :plaques, :area_id, :integer
    say_with_time("Setting addresses for existing plaques") do
      Plaque.connection.execute("update plaques p set area_id=l.area_id, address=l.name from locations l where p.location_id = l.id")
    end
  end
end
