require 'spec_helper'

describe Organisation do
  
  describe '#full_name' do
    context 'an organisation' do
      before do
        @organisation = Organisation.new(name: 'blinky')
      end
      it 'has their name displayed as-is' do
        expect(@organisation.to_s).to eq('blinky')
      end
    end

  end

  describe '#as_json' do

    context 'an organisation with nothing set' do
      before do
        @organisation = Organisation.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@organisation.as_json.to_s.size).to be > 10
      end
    end

  end

end
