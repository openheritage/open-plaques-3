class AddIntroductionToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :introduction, :text

  end
end
