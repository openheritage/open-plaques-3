require 'spec_helper'

describe Country do
  
  describe '#full_name' do
    context 'an country' do
      before do
        @country = Country.new()
      end
      it 'has their name displayed as-is' do
        expect(@country.to_s).to eq(nil)
      end
    end

  end

  describe '#as_json' do

    context 'an country with nothing set' do
      before do
        @country = Country.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@country.as_json.to_s.size).to be > 10
      end
    end

  end

  describe '#uri' do

    context 'a country with nothing set' do
      before do
        @country = Country.new()
      end
      it 'has no uri' do
        expect(@country.uri).to eq(nil)
      end
    end

    context 'a country with an id' do
      before do
        @country = Country.new(id: 13, alpha2: 'aa')
      end
      it 'has a uri' do
        # this is not ideal response. It should depend on the output format
        expect(@country.uri).to eq('http://openplaques.org/places/aa.json')
      end
    end

  end

end
