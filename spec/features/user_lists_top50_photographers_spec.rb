require 'rails_helper'

RSpec.feature 'User lists top50 photographers.', type: :feature do
  before do
    (1111..1115).each do |i|
      p = build :photo, url: "https://www.geograph.org.uk/photo/#{i}"
      p.populate
      p.save
    end
    visit '/'
  end

  scenario 'views photographers page' do
    click_on_nav_item 'Photographers'
    # should look for 'stobbo'
    expect(page).to have_main_heading 'Top 50 plaque hunters'
  end
end
