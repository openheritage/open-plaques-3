require 'rails_helper'

RSpec.feature 'Browse subjects.', type: :feature do
  before do
    (1111..1115).each do |i|
      p = build :photo, url: "https://www.geograph.org.uk/photo/#{i}"
      p.populate
      p.save
    end
  end
  scenario 'User browses photographers' do
    visit 'photographers'
    # should look for 'stobbo'
    expect(page).to have_text 'Top 50 plaque hunters'
  end
end
