require 'rails_helper'

RSpec.feature 'Browse subjects.', type: :feature do
  scenario 'User browses all subjects with surname starting with an A' do
    visit 'people/a-z/a'
    expect(page).to have_text 'Subjects of historical plaques - A'
  end
end
