class AddAbbreviationToLicences < ActiveRecord::Migration
  def change
    add_column :licences, :abbreviation, :string
  end
end
