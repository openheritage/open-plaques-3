require 'spec_helper'

describe Plaque do
  
  describe '#title' do

    context 'a plaque with nothing linked' do
      before do
        @plaque = Plaque.new()
      end
      it 'tries to state its id number (which it gets when it is saved)' do
        expect(@plaque.title).to eq('plaque № ')
      end
    end

    context 'a plaque with a subject' do
      before do
        @plaque = Plaque.new()
        @person = Person.new(name: 'Gizmo')
        @plaque.personal_connections << PersonalConnection.new(plaque: @plaque, person: @person)
      end
      it 'has the subject\'s name in it' do
        expect(@plaque.title).to eq('Gizmo plaque')
      end
    end

    context 'a plaque with a subject and a colour' do
      before do
        @plaque = Plaque.new(colour: Colour.new(name: 'blue'))
        @person = Person.new(name: 'Gizmo')
        @plaque.personal_connections << PersonalConnection.new(plaque: @plaque, person: @person)
      end
      it 'has the subject\'s name and the plaque colour in it' do
        expect(@plaque.title).to eq('Gizmo blue plaque')
      end
    end
  end

  describe '#geolocated?' do

    context 'a plaque with nothing set' do
      before do
        @plaque = Plaque.new()
      end
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end

    context 'a plaque with latitude and longitude' do
      before do
        @plaque = Plaque.new(latitude: 1335, longitude: 1234)
      end
      it 'is geolocated' do
        expect(@plaque).to be_geolocated
      end
    end

    context 'a plaque with only latitude' do
      before do
        @plaque = Plaque.new(latitude: 1335)
      end
      it 'is geolocated' do
        expect(@plaque).to be_geolocated
      end
    end

    context 'a plaque with only longitude' do
      before do
        @plaque = Plaque.new(longitude: 1335)
      end
      it 'is geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end

  end

  describe '#as_json' do

    context 'a plaque with nothing set' do
      before do
        @plaque = Plaque.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@plaque.as_json.to_s.size).to be > 10
      end
    end

  end

  describe '#uri' do

    context 'a plaque with nothing set' do
      before do
        @plaque = Plaque.new()
      end
      it 'has no uri' do
        expect(@plaque.uri).to eq(nil)
      end
    end

    context 'a plaque with an id' do
      before do
        @plaque = Plaque.new(id: 13)
      end
      it 'has a uri' do
        # this is not ideal response. It should depend on the output format
        expect(@plaque.uri).to eq('http://openplaques.org/plaques/13.json')
      end
    end

  end

end
