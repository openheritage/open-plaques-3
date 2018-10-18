describe Area, type: :model do
  it 'has a valid factory' do
    expect(create :area).to be_valid
  end
  describe '#full_name' do
    context 'with name set' do
      let (:area) { build :area, name: 'blinky' }
      it 'is nil' do
        expect(area.to_s).to eq("blinky")
      end
    end
  end

  describe '#as_json_new' do
    context 'with nothing set' do
      let (:area) { create :area }
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(area.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#uri' do
    context 'with nothing set' do
      let (:area) { create :area }
      it 'is nil' do
        expect(area.uri).to eq("http://openplaques.org/places/ab/areas/somewhere.json")
      end
    end
  end
end
