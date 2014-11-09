class RenameLicenseTableAsLicence < ActiveRecord::Migration
  def self.up
    rename_table :licenses, :licences
    rename_column :photos, :license_id, :licence_id
  end

  def self.down
    rename_column :photos, :licence_id, :license_id
    rename_table :licences, :licenses
  end
end
