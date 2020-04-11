require 'rails_helper'

describe Photo, type: :model do
  let(:nothing_set) { build :photo }

  it 'has a valid factory' do
    # file_url is only set if it is blank
    expect(create :photo, file_url: 'something').to be_valid
  end

  describe '#title' do
    context 'with nothing set' do
      it 'is \'a photo\'' do
        expect(nothing_set.title).to eq('a photo')
      end
    end
    context 'with an id' do
      let(:photo) { build :photo, id: 2300 }
      it 'is \'photo № [id]\'' do
        expect(photo.title).to eq('photo № 2300')
      end
    end
    context 'of a plaque' do
      let(:plaque) { build :plaque }
      let(:photo) { build :photo, plaque: plaque }
      it 'is \'a photo of a plaque\'' do
        expect(photo.title).to eq('a photo of a plaque')
      end
    end
    context 'of a person with a name' do
      let(:fred) { build :person, name: 'Fred' }
      let(:photo) { build :photo, person: fred }
      it 'is \'a photo of [name]]\'' do
        expect(photo.title).to eq('a photo of Fred')
      end
    end
  end

  describe '#attribution' do
    context 'with nothing set' do
      it 'is copyright on the web' do
        expect(nothing_set.attribution).to eq('&copy;  on Geograph')
      end
    end
  end

  describe '#wikimedia_data' do
    context 'of a Commons photo' do
      let(:photo) { build :photo, url: 'https://commons.wikimedia.org/wiki/File:Goderich_BCATP_Historical_Plaque.JPG' }
      before do
        photo.populate
      end
      it 'has a file_url' do
        expect(photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/Goderich_BCATP_Historical_Plaque.JPG?width=640')
      end
    end
    context 'of a Commons photo wiki page' do
      let(:photo) { build :photo, url: 'https://commons.wikimedia.org/wiki/Dog#/media/File:DogDewClawTika1_wb.jpg' }
      before do
        photo.populate
      end
      it 'has a file_url' do
        expect(photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/DogDewClawTika1_wb.jpg?width=640')
      end
    end
    context 'a Commons upload photo' do
      let(:photo) { build :photo, url: 'https://upload.wikimedia.org/wikipedia/commons/4/49/DogDewClawTika1_wb.jpg' }
      before do
        photo.populate
      end
      it 'has a file_url' do
        expect(photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/DogDewClawTika1_wb.jpg?width=640')
      end
    end
  end

  describe '#flickr_photo_id' do
    context 'of a Flickr url from an album' do
      it 'has a photo id' do
        expect(Photo.flickr_photo_id('https://www.flickr.com/photos/josemoya/36584194011/in/album-72157667474637461/')).to eq('36584194011')
      end
    end
    context 'of a Flickr url with trailing slash' do
      it 'has a photo id' do
        expect(Photo.flickr_photo_id('https://www.flickr.com/photos/josemoya/36584194011/')).to eq('36584194011')
      end
    end
    context 'of a Flickr url' do
      it 'has a photo id' do
        expect(Photo.flickr_photo_id('https://www.flickr.com/photos/josemoya/36584194011')).to eq('36584194011')
      end
    end
    context 'of a http Flickr url' do
      it 'has a photo id' do
        expect(Photo.flickr_photo_id('http://www.flickr.com/photos/josemoya/36584194011')).to eq('36584194011')
      end
    end
    context 'of a non Flickr url' do
      it 'has no photo id' do
        expect(Photo.flickr_photo_id('http://ruby.bastardsbook.com/chapters/regexes/')).to be nil
      end
    end
  end

  describe 'setting Geograph data' do
    context 'of a Geograph photo' do
      let(:photo) { build :photo, url: 'https://www.geograph.org.uk/photo/5561265' }
      before do
        photo.populate
      end
      it 'has a file url' do
        expect(photo.file_url).to eq('https://s0.geograph.org.uk/geophotos/05/56/12/5561265_bc74db7d.jpg')
      end
    end
  end
end
