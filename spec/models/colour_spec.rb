require 'spec_helper'

describe Colour do
  
  describe '#full_name' do
    context 'a colour' do
      before do
        @colour = Colour.new()
      end
      it 'has their name displayed as-is' do
        expect(@colour.to_s).to eq(nil)
      end
    end

  end

  describe '#as_json' do

    context 'a colour with nothing set' do
      before do
        @colour = Colour.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@colour.as_json.to_s.size).to be > 10
      end
    end

  end

end
