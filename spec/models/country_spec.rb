require 'rails_helper'

describe Country, type: :model do
  it 'has a valid factory' do
    expect(create :country).to be_valid
  end

  describe '#geolocated?' do
  end

  describe '#plaques_count' do
    context 'with nothing set' do
      let(:country) { build :country }
      it 'is zero' do
        expect(country.plaques_count).to eq(0)
      end
    end
    context 'with a plaque' do
      let(:country) { create :country }
      let(:area) { create :area, country: country }
      let(:plaque_1) { create :plaque, area: area }
      it 'is 1' do
#        expect(country.plaques_count).to eq(1)
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      let(:country) { build :country }
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(country.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#uri' do
    context 'unsaved' do
      let(:country) { build :country }
      it 'is nil' do
        expect(country.uri).to eq(nil)
      end
    end

    context 'with an id' do
      let(:country) { create :country }
      it 'is an http address' do
        expect(country.uri).to eq("http://openplaques.org/places/#{country.alpha2}.json")
      end
    end
  end

  describe '#to_s' do
    context 'with nothing set' do
      let(:country) { build :country, name: nil }
      it 'is blank' do
        expect(country.to_s).to eq('')
      end
    end

    context 'with a name set' do
      let(:country) { build :country, name: 'binky' }
      it 'is nil' do
        expect(country.name).to eq('binky')
      end
    end
  end
end
