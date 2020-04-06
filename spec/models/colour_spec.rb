require 'rails_helper'

describe Colour, type: :model do
  it 'has a valid factory' do
    expect(create :colour).to be_valid
  end

  describe '#as_json' do
    context 'with nothing set' do
      let(:colour) { build :colour }
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(colour.as_json.to_s.size).to be > 10
      end
    end
  end
end
