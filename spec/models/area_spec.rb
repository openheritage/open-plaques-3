require 'spec_helper'

describe Area, type: :model do
  it 'has a valid factory' do
    expect(create(:area)).to be_valid
  end
  describe '#full_name' do
    context 'with nothing set' do
      before do
        @area = Area.new
      end
      it 'is nil' do
        expect(@area.to_s).to eq(nil)
      end
    end
  end

  describe '#as_json_new' do
    context 'with nothing set' do
      before do
        @area = Area.new
      end
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@area.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#uri' do
    context 'with nothing set' do
      before do
        @area = Area.new
      end
      it 'is nil' do
        expect(@area.uri).to eq(nil)
      end
    end

    context 'with an id' do
      before do
        @area = Area.new(id: 13)
      end
      it 'is nil' do
        # this is not ideal response. It should depend on the output format
        expect(@area.uri).to eq(nil)
      end
    end

    context 'with an id and a country' do
      before do
        @area = Area.new(id: 13)
        @country = Country.new(id: 1, name: 'Monrovia', alpha2: 'mo')
        @country.areas << @area
        @area.country = @country
      end
      it 'is an http address' do
        # this is not ideal response. It should depend on the output format
        #       expect(@area.uri).to eq('http://openplaques.org/plaques/13.json')
      end
    end
  end
end
