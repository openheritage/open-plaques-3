require 'rails_helper'

RSpec.feature 'AddPlaques', type: :feature do
  scenario 'User creates a new plaque' do
    visit '/plaques/new?checked=true&phrase=wibble'
    fill_in(:plaque_inscription, with: 'only the lonely')
    click_button :commit
    expect(page).to have_text('Thanks for adding this plaque.')
  end

  scenario 'Spammer tries to create a new plaque' do
    visit '/plaques/new?checked=true&phrase=wibble'
    fill_in(:plaque_inscription, with: '<a href="http://spamtastic.com/youre_hooked">clik me</a>')
    click_button :commit
    expect(page).to have_text('Latest 20 plaques')
  end
end
