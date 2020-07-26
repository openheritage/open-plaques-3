require 'rails_helper'

RSpec.feature 'Admin adds a subject.', type: :feature do
  let(:admin) { create(:user) }

  before do
    login_as(admin, scope: :user)
    visit '/'
  end

  scenario 'add a subject with a name' do
    click_on_nav_item 'Subjects'
    click_on 'add'
    p = build :person
    fill_in :person_name, with: p.name
    click_button :commit
    expect(page).to have_text 'Person was successfully created.'
  end
end
