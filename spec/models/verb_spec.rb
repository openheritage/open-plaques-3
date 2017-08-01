require 'spec_helper'

describe Verb, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:verb)).to be_valid
  end
end
