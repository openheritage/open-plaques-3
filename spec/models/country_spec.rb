describe Country, type: :model do
  it 'has a valid factory' do
    expect(create(:country)).to be_valid
  end
  describe '#full_name' do
    context 'with nothing set' do
      before do
        @country = Country.new
      end
      it 'is nil' do
        expect(@country.to_s).to eq(nil)
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      before do
        @country = Country.new
      end
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@country.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#uri' do
    context 'with nothing set' do
      before do
        @country = Country.new
      end
      it 'is nil' do
        expect(@country.uri).to eq(nil)
      end
    end

    context 'with an id' do
      before do
        @country = Country.new(id: 13, alpha2: 'aa')
      end
      it 'is an http address' do
        # this is not ideal response. It should depend on the output format
        expect(@country.uri).to eq('http://openplaques.org/places/aa.json')
      end
    end
  end
end
