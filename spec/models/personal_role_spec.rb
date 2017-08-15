require 'spec_helper'

describe PersonalRole, type: :model do
  it 'has a valid factory' do
    expect(create(:personal_role)).to be_valid
  end
end
