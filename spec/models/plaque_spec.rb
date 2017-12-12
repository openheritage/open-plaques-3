describe Plaque, type: :model do
  it 'has a valid factory' do
    expect(create(:plaque)).to be_valid
  end
  describe '#machine_tag' do
    context 'built' do
      let (:plaque) { build :plaque }
      it 'is \'openplaques:id=\'' do
        expect(plaque.machine_tag).to eq('openplaques:id=')
      end
    end
    context 'created' do
      let (:plaque) { create :plaque }
      it 'is \'openplaques:id=[d]*\'' do
        expect(plaque.machine_tag).to match(/openplaques:id=[d]*/)
      end
    end
  end
  describe '#wikimedia_tag' do
    context 'built' do
      let (:plaque) { build :plaque }
      it 'is \'plaque number [id]\'' do
        expect(plaque.wikimedia_tag).to eq('{{Open Plaques|plaqueid=}}')
      end
    end
    context 'created' do
      let (:plaque) { create :plaque }
      it 'is \'plaque number [id]\'' do
        expect(plaque.wikimedia_tag).to match(/{{Open Plaques|plaqueid=[d]*}}/)
      end
    end
  end
  describe '#title' do
    context 'with nothing linked' do
      let (:plaque) { build :plaque, id: 666 }
      it 'is \'plaque number [id]\'' do
        expect(plaque.title).to eq('plaque № 666')
      end
    end
    context 'with a subject' do
      let (:plaque) { build :plaque, id: 666 }
      let (:person) { build :person, name: 'Gizmo' }
      let (:verb) { build :verb }
      let (:pc) { build :personal_connection, plaque: plaque, person: person, verb: verb }
      before do
        plaque.personal_connections << pc
      end
      it 'is \'[subject\'s name] plaque\'' do
        expect(plaque.title).to eq('Gizmo plaque')
      end
    end
    context 'with a subject and a colour' do
      let (:blue) { build :colour, name: 'blue' }
      let (:plaque) { build :plaque, colour: blue }
      let (:person) { build :person, name: 'Gizmo' }
      let (:verb) { build :verb }
      let (:pc) { build :personal_connection, plaque: plaque, person: person, verb: verb }
      before do
        plaque.personal_connections << pc
      end
      it 'is \'[subject\'s name] [plaque colour] plaque\'' do
        expect(plaque.title).to eq('Gizmo blue plaque')
      end
    end
  end

  describe 'geo accuracy' do
    context 'given detailed geolocation' do
      let (:plaque) { build :plaque, latitude: -79.40822346, longitude: 43.677634565 }
      it 'is latitude to 5 decimal places' do
        expect(plaque.latitude).to eq(-79.40822)
      end
      it 'is longitude to 5 decimal places' do
        expect(plaque.longitude).to eq(43.67763)
      end
    end
  end

  describe '#geolocated?' do
    context 'with neither latitude nor longitude' do
      let (:plaque) { build :plaque }
      it 'is not geolocated' do
        expect(plaque).to_not be_geolocated
      end
    end
    context 'with latitude and longitude' do
      let (:plaque) { build :plaque, latitude: 0.121, longitude: -0.123 }
      it 'is geolocated' do
        expect(plaque).to be_geolocated
      end
    end
    context 'with latitude only' do
      let (:plaque) { build :plaque, latitude: 0.121 }
      it 'is not geolocated' do
        expect(plaque).to_not be_geolocated
      end
    end
    context 'with longitude only' do
      let (:plaque) { build :plaque, longitude: -0.123 }
      it 'is not geolocated' do
        expect(plaque).to_not be_geolocated
      end
    end
  end

  describe '#as_json of' do
    context 'with nothing set' do
      let (:plaque) { build :plaque }
      it 'is json' do
        # can do better than this
        # Probably by using https://github.com/collectiveidea/json_spec
        expect(plaque.as_json.to_s.size).to be > 10
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
      let (:plaque) { build :plaque, id: 13}
      it 'is \'openplaques.org/plaques/[id]\'' do
        # this is not ideal response. It should depend on the output format
        expect(plaque.uri).to eq('http://openplaques.org/plaques/13')
      end
    end
  end

  describe '#as_wkt' do
    context 'with nothing set' do
      let (:plaque) { build :plaque }
      it 'is nil' do
        expect(plaque.as_wkt).to eq("")
      end
    end
    context 'with nothing set' do
      let (:plaque) { build :plaque, latitude: 0.121, longitude: -0.123 }
      it 'is nil' do
        expect(plaque.as_wkt).to eq("POINT(-0.123 0.121)")
      end
    end
  end
end
