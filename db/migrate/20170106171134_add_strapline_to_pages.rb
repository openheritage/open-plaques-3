class AddStraplineToPages < ActiveRecord::Migration
  def change
    add_column :pages, :strapline, :string
  end
end
