describe Licence, type: :model do
  let(:blinky) { build :licence, name: 'blinky' }
  let(:cc_by_2) { build :licence, name: 'cc_by_2', url: 'http://creativecommons.org/licenses/by/2.0/' }
  let(:usa_gov) { build :licence, name: 'USA Gov', url: 'http://www.usa.gov/copyright.shtml' }

  it 'has a valid factory' do
    expect(create(:licence)).to be_valid
  end

  describe '#to_s' do
    context 'with a name' do
      it 'is their name' do
        expect(blinky.to_s).to eq('blinky')
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(blinky.as_json.to_s.size).to be > 10
      end
    end
    context 'cc_by_2' do
      it 'is json' do
        expect(cc_by_2.as_json.to_s.size).to be > 10
      end
    end
  end

  describe '#creative_commons?' do
    context 'with nothing set' do
      it 'is false' do
        expect(blinky.creative_commons?).to be_falsey
      end
    end
    context 'cc_by_2' do
      it 'is true' do
        expect(cc_by_2.creative_commons?).to be_truthy
      end
    end
    context 'USA Gov' do
      it 'is false' do
        expect(usa_gov.creative_commons?).to be_falsey
      end
    end
  end
end
