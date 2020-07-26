require 'rails_helper'

RSpec.feature 'User browses subjects.', type: :feature do
  before do
    visit '/'
    click_on_nav_item 'Subjects'
  end

  scenario 'clicking Subjects in the menu' do
    expect(page).to have_text 'Subjects of historical plaques - A'
  end

  scenario 'clicking a letter' do
    within '#alphabetical-navbar' do
      click_on 'H'
    end
    expect(page).to have_text 'Subjects of historical plaques - H'
  end
end
