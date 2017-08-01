require 'spec_helper'

describe Series, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:series)).to be_valid
  end
end
