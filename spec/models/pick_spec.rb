require 'spec_helper'

describe Pick, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:pick)).to be_valid
  end
end
