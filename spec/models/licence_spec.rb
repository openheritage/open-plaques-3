describe Licence, type: :model do
  it 'has a valid factory' do
    expect(create(:licence)).to be_valid
  end
  describe '#to_s' do
    context 'with a name' do
      before do
        @licence = Licence.new(name: 'blinky')
      end
      it 'is their name' do
        expect(@licence.to_s).to eq('blinky')
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      before do
        @licence = Licence.new
      end
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@licence.as_json.to_s.size).to be > 10
      end
    end
  end
end
