class AddProposerToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :proposer, :string
  end
end
