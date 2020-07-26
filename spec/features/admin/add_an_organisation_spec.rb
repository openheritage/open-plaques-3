require 'rails_helper'

RSpec.feature 'Admin adds an organisation.', type: :feature do
  let(:admin) { create(:user) }

  before do
    login_as(admin, scope: :user)
    visit '/'
  end

  scenario 'click add on the org page' do
    click_on_nav_item 'Organisations'
    click_on 'add'
    o = build :organisation
    fill_in :organisation_name, with: o.name
    click_button :commit
    expect(page).to have_text 'Thanks for adding this'
  end
end
