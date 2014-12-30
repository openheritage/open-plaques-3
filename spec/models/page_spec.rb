require 'spec_helper'

describe Page do
  
  describe '#name' do
    context 'a page' do
      before do
        @page = Page.new(name: 'blinky')
      end
      it 'has their name displayed as-is' do
        expect(@page.to_s).to eq('blinky')
      end
    end

  end

  describe '#as_json' do

    context 'a page with nothing set' do
      before do
        @page = Page.new()
      end
      it 'returns json' do
        # can do better than this. Probably by using https://github.com/collectiveidea/json_spec
        expect(@page.as_json.to_s.size).to be > 10
      end
    end

  end

end
