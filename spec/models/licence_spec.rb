require 'spec_helper'

describe Licence do
  
  describe '#full_name' do
    context 'a licence' do
      before do
        @licence = Licence.new(name: 'blinky')
      end
      it 'has their name displayed as-is' do
        expect(@licence.to_s).to eq('blinky')
      end
    end

  end

  describe '#as_json' do

    context 'a licence with nothing set' do
      before do
        @licence = Licence.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@licence.as_json.to_s.size).to be > 10
      end
    end

  end

end
