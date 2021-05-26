require 'rails_helper'

RSpec.feature 'User browses areas.', type: :feature do
  before do
    20.times do
      begin
        area_in_the_uk = create :area, country: Country.uk
      rescue
      end
      plaque = create :plaque, area: Country.uk.areas.random
    end
    visit '/'
    click_on_nav_item 'Places'
  end

  scenario 'main index' do
    expect(page).to have_main_heading('Countries that have plaques')
  end

  scenario 'main index' do
    click_on 'United Kingdom'
    expect(page).to have_sub_heading('Areas')
  end
end
