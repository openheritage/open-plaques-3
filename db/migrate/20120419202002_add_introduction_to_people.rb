class AddIntroductionToPeople < ActiveRecord::Migration
  def change
    add_column :people, :introduction, :text

  end
end
