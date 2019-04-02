class AddAbbreviationToLicences < ActiveRecord::Migration[4.2]
  def change
    add_column :licences, :abbreviation, :string
  end
end
