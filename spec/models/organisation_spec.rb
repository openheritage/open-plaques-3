describe Organisation, type: :model do
  it 'has a valid factory' do
    expect(create :organisation).to be_valid
  end

  describe '#to_s' do
    context 'with a name' do
      let (:organisation) { build :organisation, name: 'blinky' }
      it 'is their name' do
        expect(organisation.to_s).to eq('blinky')
      end
    end
  end

  describe '#as_json' do
    context 'with nothing set' do
      let (:organisation) { create :organisation, name: 'blinky' }
      it 'is json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(organisation.as_json.to_s.size).to be > 10
      end
    end
  end
end
