describe Colour, type: :model do
  it 'has a valid factory' do
    expect(create(:colour)).to be_valid
  end
  describe '#full_name' do
    context 'with nothing set' do
      before do
        @colour = Colour.new
      end
      it 'is nil' do
        expect(@colour.to_s).to eq(nil)
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      before do
        @colour = Colour.new
      end
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@colour.as_json.to_s.size).to be > 10
      end
    end
  end
end
