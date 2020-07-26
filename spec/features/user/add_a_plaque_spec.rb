require 'rails_helper'

RSpec.feature 'User adds a plaque.', type: :feature do
  scenario 'User searches for a person then creates a new plaque' do
    p = build :person
    visit '/'
    fill_in :phrase, with: p.name
    click_button :gosearch
    expect(page).to have_text 'Can\'t find what you\'re looking for?'
    click_link :goadd
    click_button :commit
    expect(page).to have_text 'Thanks for adding this'
  end

  scenario 'Spammer tries to inject html in a new plaque' do
    visit '/plaques/new?checked=true'
    fill_in(:plaque_inscription, with: '<a href="http://spamtastic.com/youre_hooked">clik me</a>')
    click_button :commit
    expect(page).to have_text('Latest 20 plaques')
  end
end
