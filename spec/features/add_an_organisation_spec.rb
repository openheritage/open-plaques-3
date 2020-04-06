require 'rails_helper'

RSpec.feature 'Add an organisation.', type: :feature do
  let(:admin) { create(:user) }

  before do
    login_as(admin, scope: :user)
  end

  scenario 'Admin visits the add org page' do
    visit 'organisations/new'
    fill_in :organisation_name, with: Faker::Company.name
    click_button :commit
    expect(page).to have_text 'Thanks for adding this'
  end
end
