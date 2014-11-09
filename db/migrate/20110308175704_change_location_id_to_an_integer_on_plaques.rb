class ChangeLocationIdToAnIntegerOnPlaques < ActiveRecord::Migration

  # redefining the Plaque class so that we don't have to deal with validations.
  class Plaque < ActiveRecord::Base
  end

  def self.up

    rename_column :plaques, :location_id, :location_id_old  # temporarily rename the column
    add_column :plaques, :location_id, :integer  # add the column again but as an integer


    say_with_time "Copying values from old column to new column" do
      Plaque.find_each do |plaque|
        unless plaque.location_id_old.blank?
          plaque.update_attributes(:location_id => plaque.location_id_old.to_i)
        end
      end
    end

    remove_column :plaques, :location_id_old

  end

  def self.down
    change_column :plaques, :location_id, :string
  end
end