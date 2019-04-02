class AddLicenseIdToPhoto < ActiveRecord::Migration[4.2]
  def self.up
    add_column :photos, :license_id, :integer
  end

  def self.down
    remove_column :photos, :license_id
  end
end
