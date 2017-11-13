require 'spec_helper'

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
    context 'an unambiguous name' do
      it 'returns a Wikidata id' do
        expect(Wikidata.qcode('Myra Hess')).to eq("Q269848")
      end
    end
  end

  describe '#en_wikipedia_url' do
    context 'a Wikidata id' do
      it 'returns a url' do
        expect(Wikidata.en_wikipedia_url("Q269848")).to eq("https://en.wikipedia.org/wiki/Myra_Hess")
      end
    end
    context 'nil' do
      it 'returns nil' do
        expect(Wikidata.en_wikipedia_url(nil)).to eq(nil)
      end
    end
    context 'a non Wikidata id' do
      it 'returns nil' do
        expect(Wikidata.en_wikipedia_url("blah")).to eq(nil)
      end
    end
    context 'an unknown Wikidata id' do
      it 'returns nil' do
        expect(Wikidata.en_wikipedia_url("Q99999999999999")).to eq(nil)
      end
    end
  end
end
