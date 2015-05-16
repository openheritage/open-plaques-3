require 'spec_helper'

describe Area do
  
  describe '#full_name' do
    context 'an area' do
      before do
        @area = Area.new()
      end
      it 'has their name displayed as-is' do
        expect(@area.to_s).to eq(nil)
      end
    end

  end

  describe '#as_json_new' do

    context 'an area with nothing set' do
      before do
        @area = Area.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@area.as_json.to_s.size).to be > 10
      end
    end

  end

  describe '#uri' do

    context 'an area with nothing set' do
      before do
        @area = Area.new()
      end
      it 'has no uri' do
        expect(@area.uri).to eq(nil)
      end
    end

    context 'an area with an id' do
      before do
        @area = Area.new(id: 13)
      end
      it 'has no uri' do
        # this is not ideal response. It should depend on the output format
        expect(@area.uri).to eq(nil)
      end
    end

    context 'an area with an id and a country' do
      before do
        @area = Area.new(id: 13)
        @country = Country.new(id: 1, name: 'Monrovia', alpha2: 'mo')
        @country.areas << @area
        @area.country = @country
      end
      it 'has a uri' do
        # this is not ideal response. It should depend on the output format
#       expect(@area.uri).to eq('http://openplaques.org/plaques/13.json')
      end
    end

  end

end
