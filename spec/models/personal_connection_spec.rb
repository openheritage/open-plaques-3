require 'spec_helper'

describe PersonalConnection, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:personal_connection)).to be_valid
  end
end
