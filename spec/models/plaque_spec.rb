require 'spec_helper'

describe Plaque, type: :model do
  it 'has a valid factory' do
    expect(create(:plaque)).to be_valid
  end
  describe '#title' do
    context 'with nothing linked' do
      before do
        @plaque = Plaque.new(id: 666)
      end
      it 'is \'plaque number [id]\'' do
        expect(@plaque.title).to eq('plaque № 666')
      end
    end
    context 'with a subject' do
      before do
        @plaque = Plaque.new
        @person = Person.new(name: 'Gizmo')
        @verb = Verb.new
        pc = PersonalConnection.new(
          plaque: @plaque, person: @person, verb: @verb
        )
        @plaque.personal_connections << pc
      end
      it 'is \'[subject\'s name] plaque\'' do
        expect(@plaque.title).to eq('Gizmo plaque')
      end
    end
    context 'with a subject and a colour' do
      before do
        @plaque = Plaque.new(colour: Colour.new(name: 'blue'))
        @person = Person.new(name: 'Gizmo')
        @verb = Verb.new
        pc = PersonalConnection.new(
          plaque: @plaque, person: @person, verb: @verb
        )
        @plaque.personal_connections << pc
      end
      it 'is \'[subject\'s name] [plaque colour] plaque\'' do
        expect(@plaque.title).to eq('Gizmo blue plaque')
      end
    end
  end

  describe 'geo accuracy' do
    context 'given detailed geolocation' do
      before do
        @plaque = Plaque.new(latitude: -79.40822346, longitude: 43.677634565)
      end
      it 'is latitude to 5 decimal places' do
        expect(@plaque.latitude).to eq(-79.40822)
      end
      it 'is longitude to 5 decimal places' do
        expect(@plaque.longitude).to eq(43.67763)
      end
    end
  end

  describe '#geolocated?' do
    context 'with neither latitude nor longitude' do
      before do
        @plaque = Plaque.new
      end
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end
    context 'with latitude and longitude' do
      before do
        @plaque = Plaque.new(latitude: 1335, longitude: 1234)
      end
      it 'is geolocated' do
        expect(@plaque).to be_geolocated
      end
    end
    context 'with latitude only' do
      before do
        @plaque = Plaque.new(latitude: 1335)
      end
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end
    context 'with longitude only' do
      before do
        @plaque = Plaque.new(longitude: 1335)
      end
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end
  end

  describe '#as_json of' do
    context 'with nothing set' do
      before do
        @plaque = Plaque.new
      end
      it 'is json' do
        # can do better than this
        # Probably by using https://github.com/collectiveidea/json_spec
        expect(@plaque.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#uri' do
    context 'with nothing set' do
      before do
        @plaque = Plaque.new
      end
      it 'is nil' do
        expect(@plaque.uri).to eq(nil)
      end
    end
    context 'with an id' do
      before do
        @plaque = Plaque.new(id: 13)
      end
      it 'is \'openplaques.org/plaques/[id]\'' do
        # this is not ideal response. It should depend on the output format
        expect(@plaque.uri).to eq('http://openplaques.org/plaques/13')
      end
    end
  end
end
