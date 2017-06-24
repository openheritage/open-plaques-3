require 'spec_helper'

describe Plaque do

  describe 'the #title of' do
    context 'a plaque with nothing linked' do
      before do
        @plaque = Plaque.new(id: 666)
      end
      it 'states its id number (which it gets when it is saved)' do
        expect(@plaque.title).to eq('plaque number 666')
      end
    end
    context 'a plaque with a subject' do
      before do
        @plaque = Plaque.new
        @person = Person.new(name: 'Gizmo')
        @verb = Verb.new
        @plaque.personal_connections << PersonalConnection.new(plaque: @plaque, person: @person, verb: @verb)
      end
      it 'has the subject\'s name in it' do
        expect(@plaque.title).to eq('Gizmo plaque')
      end
    end
    context 'a plaque with a subject and a colour' do
      before do
        @plaque = Plaque.new(colour: Colour.new(name: 'blue'))
        @person = Person.new(name: 'Gizmo')
        @verb = Verb.new
        @plaque.personal_connections << PersonalConnection.new(plaque: @plaque, person: @person, verb: @verb)
      end
      it 'has the subject\'s name and the plaque colour in it' do
        expect(@plaque.title).to eq('Gizmo blue plaque')
      end
    end
  end

  describe 'the geo accuracy' do
    context 'of a plaque given detailed geolocation' do
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
    context 'a plaque with no latitude or longitude' do
      before do
        @plaque = Plaque.new
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
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end
    context 'a plaque with only longitude' do
      before do
        @plaque = Plaque.new(longitude: 1335)
      end
      it 'is not geolocated' do
        expect(@plaque).to_not be_geolocated
      end
    end
  end

  describe '#as_json of' do
    context 'a plaque with nothing set' do
      before do
        @plaque = Plaque.new()
      end
      it 'is some json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@plaque.as_json.to_s.size).to be > 10
      end
    end
  end

  describe 'the #uri of' do
    context 'a plaque with nothing set' do
      before do
        @plaque = Plaque.new()
      end
      it 'is nil' do
        expect(@plaque.uri).to eq(nil)
      end
    end
    context 'a plaque with an id' do
      before do
        @plaque = Plaque.new(id: 13)
      end
      it 'is openplaques.org/plaques/ and the id' do
        # this is not ideal response. It should depend on the output format
        expect(@plaque.uri).to eq('http://openplaques.org/plaques/13')
      end
    end
  end

end
