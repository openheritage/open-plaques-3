require 'rails_helper'

RSpec.feature 'Admin adds a role.', type: :feature do
  let(:admin) { create(:user) }

  before do
    login_as(admin, scope: :user)
    visit '/'
  end

  scenario 'add a role with a name' do
    r = build :role
    click_on_nav_item 'Roles'
    click_on 'add'
    fill_in :role_name, with: r.name
    click_button :commit
    expect(page).to have_text 'was successfully created'
  end
end
