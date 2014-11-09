class AddLicenseIdToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :license_id, :integer
  end

  def self.down
    remove_column :photos, :license_id
  end
end
