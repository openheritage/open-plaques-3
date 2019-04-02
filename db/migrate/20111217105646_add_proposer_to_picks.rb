class AddProposerToPicks < ActiveRecord::Migration[4.2]
  def change
    add_column :picks, :proposer, :string
  end
end
