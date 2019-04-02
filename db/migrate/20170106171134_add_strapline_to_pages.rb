class AddStraplineToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :strapline, :string
  end
end
