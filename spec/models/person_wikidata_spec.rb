require 'rails_helper'

describe Person, type: :model do
  let(:a_person) { build :person }
  let(:john_smith) { build :person, name: 'John Smith' }

  describe '#fill_wikidata_id' do
    context 'an unfindable name' do
      let(:zdfgad) { build :person, name: 'zdfgad' }
      before do
        zdfgad.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(zdfgad.wikidata_id).to eq(nil)
      end
    end
    context 'an ambiguous name' do
      before do
        a_person.name = "John Smith"
        a_person.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(a_person.wikidata_id).to eq(nil)
      end
    end
  end

  describe '#wikipedia_url' do
    context 'with no wikidata id' do
      it 'has no Wikidata' do
        expect(a_person.wikipedia_url).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      before do
        a_person.wikidata_id = 'Q269848'
      end
      it 'has a wikipedia url' do
        expect(a_person.wikipedia_url).to eq('https://en.wikipedia.org/wiki/Myra_Hess')
      end
    end
  end

  describe '#dbpedia_abstract' do
    context 'with no wikidata id' do
      it 'has no dbpedia' do
        expect(a_person.dbpedia_abstract).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      before do
        a_person.wikidata_id = 'Q8016'
      end
      it 'has a dbpedia abstract' do
        expect(a_person.dbpedia_abstract).to include('Winston Leonard Spencer Churchill')
      end
    end
  end
end
