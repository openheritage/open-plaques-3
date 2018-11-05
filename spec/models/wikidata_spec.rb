describe Wikidata do
  describe '#search_wikidata' do
    context 'an unfindable name' do
      it 'returns nothing' do
        expect(Wikidata.qcode('zdfgad')).to eq(nil)
      end
    end
    context 'an ambiguous name' do
      it 'returns nothing' do
        expect(Wikidata.qcode('John Smith')).to eq(nil)
      end
    end
    context 'an ambiguous name with dates' do
      it 'returns someone with the right name and dates' do
        expect(Wikidata.qcode('James Duffy (1889-1969)')).to eq("Q4155328")
      end
    end
    context 'an ambiguous name with only death date' do
      it 'returns someone with the right name and dates' do
        expect(Wikidata.qcode('James Duffy (d.1969)')).to eq("Q4155328")
      end
    end
    context 'an ambiguous name with only birth date' do
      it 'returns someone with the right name and dates' do
        expect(Wikidata.qcode('James Duffy (b.1889)')).to eq("Q4155328")
      end
    end
    context 'an unambiguous name' do
      it 'returns a Wikidata id' do
        expect(Wikidata.qcode('Myra Hess')).to eq("Q269848")
      end
    end
    context 'an unambiguous name with the right dates' do
      it 'returns a Wikidata id' do
        expect(Wikidata.qcode('Myra Hess (1890-1965)')).to eq("Q269848")
      end
    end
    context 'a name which Wikidata do not match' do
      it 'returns a Wikidata id' do
        expect(Wikidata.qcode('abolitionist')).to eq(nil)
      end
    end
    context 'a name which Wikidata hold starting with uppercase' do
      it 'returns a Wikidata id' do
        expect(Wikidata.qcode('anchorite')).to eq("Q1146843")
      end
    end
    context 'a name with an unusual character' do
      it 'returns nil' do
        expect(Wikidata.qcode('Discoverer of the variation of δ CEPHEI and other stars')).to be_truthy
      end
    end
  end

  describe '#en_wikipedia_url' do
    context 'a Wikidata id' do
      let (:wikidata) { Wikidata.new("Q269848") }
      it 'is an en wikipedia url' do
        expect(wikidata.en_wikipedia_url).to start_with("https://en.wikipedia.org/wiki/")
      end
    end
    context 'nil' do
      let (:wikidata) { Wikidata.new(nil) }
      it 'is nil' do
        expect(wikidata.en_wikipedia_url).to eq(nil)
      end
    end
    context 'a non Wikidata id' do
      let (:wikidata) { Wikidata.new("blah") }
      it 'is nil' do
        expect(wikidata.en_wikipedia_url).to eq(nil)
      end
    end
    context 'an unknown Wikidata id' do
      let (:wikidata) { Wikidata.new("Q99999999999999") }
      it 'is nil' do
        expect(wikidata.en_wikipedia_url).to eq(nil)
      end
    end
  end

  describe '#born_in' do
    context 'a Wikidata id' do
      let (:wikidata) { Wikidata.new("Q269848") }
      it 'is a year' do
        expect(wikidata.born_in).to match(/\d\d\d\d/)
      end
    end
    context 'nil' do
      let (:wikidata) { Wikidata.new(nil) }
      it 'is nil' do
        expect(wikidata.born_in).to eq(nil)
      end
    end
    context 'a non Wikidata id' do
      let (:wikidata) { Wikidata.new("boop") }
      it 'is nil' do
        expect(wikidata.born_in).to eq(nil)
      end
    end
    context 'an unknown Wikidata id' do
      let (:wikidata) { Wikidata.new("Q2341414123421") }
      it 'is nil' do
        expect(wikidata.born_in).to eq(nil)
      end
    end
  end

  describe '#disambiguation?' do
    context 'a Wikidata id' do
      let (:wikidata) { Wikidata.new("Q269848") }
      it 'is not ambiguous' do
        expect(wikidata.disambiguation?).to be_falsy
      end
    end
    context 'a disambiguation page Wikidata id' do
      let (:wikidata) { Wikidata.new("Q255563") }
      it 'is ambiguous' do
        expect(wikidata.disambiguation?).to be_truthy
      end
    end
    context 'nil' do
      let (:wikidata) { Wikidata.new(nil) }
      it 'is not ambiguous' do
        expect(wikidata.disambiguation?).to be_falsy
      end
    end
    context 'a non Wikidata id' do
      let (:wikidata) { Wikidata.new("boop") }
      it 'is not ambiguous' do
        expect(wikidata.disambiguation?).to be_falsy
      end
    end
    context 'an unknown Wikidata id' do
      let (:wikidata) { Wikidata.new("Q2341414123421") }
      it 'is not ambiguous' do
        expect(wikidata.disambiguation?).to be_falsy
      end
    end
  end
end
