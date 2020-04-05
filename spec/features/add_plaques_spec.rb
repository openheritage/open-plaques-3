require 'rails_helper'

RSpec.feature 'Add a plaque.', type: :feature do
  scenario 'User searches for a person then creates a new plaque' do
    visit '/'
    fill_in :phrase, with: Faker::Name.name
    click_button :gosearch
    expect(page).to have_text 'Can\'t find what you\'re looking for?'
    click_link :goadd
    click_button :commit
    expect(page).to have_text 'Thanks for adding this plaque.'
  end

  scenario 'Spammer tries to create a new plaque' do
    visit '/plaques/new?checked=true'
    fill_in(:plaque_inscription, with: '<a href="http://spamtastic.com/youre_hooked">clik me</a>')
    click_button :commit
    expect(page).to have_text('Latest 20 plaques')
  end
end