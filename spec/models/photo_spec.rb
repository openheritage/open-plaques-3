describe Photo, type: :model do
  it 'has a valid factory' do
    expect(create(:photo)).to be_valid
  end
  describe '#title' do
    context 'with nothing set' do
      before do
        @photo = Photo.new
      end
      it 'is \'a photo\'' do
        expect(@photo.title).to eq('a photo')
      end
    end
    context 'with an id' do
      before do
        @photo = Photo.new(id: 2300)
      end
      it 'is \'photo № [id]\'' do
        expect(@photo.title).to eq('photo № 2300')
      end
    end
    context 'of a plaque' do
      before do
        @photo = Photo.new
        @photo.plaque = Plaque.new
      end
      it 'is \'a photo of a plaque\'' do
        expect(@photo.title).to eq('a photo of a plaque')
      end
    end
    context 'of a person with a name' do
      before do
        @photo = Photo.new
        @photo.person = Person.new(name: 'Fred')
      end
      it 'is \'a photo of [name]]\'' do
        expect(@photo.title).to eq('a photo of Fred')
      end
    end
  end

  describe '#attribution' do
    context 'with nothing set' do
      before do
        @photo = Photo.new
      end
      it 'is copyright on the web' do
        expect(@photo.attribution).to eq('&copy;  on the web')
      end
    end
    context 'of a Commons photo' do
      before do
        @photo = Photo.new(url: 'https://commons.wikimedia.org/wiki/File:Goderich_BCATP_Historical_Plaque.JPG')
        @photo.wikimedia_data
      end
      it 'includes a commons licence statement' do
        expect(@photo.attribution).to eq(
          '&copy; SteveTheAirman on Wikimedia Commons CC BY-SA 3.0'
        )
      end
    end
  end

  describe '#wikimedia_data' do
    context 'of a Commons photo' do
      before do
        @photo = Photo.new(url: 'https://commons.wikimedia.org/wiki/File:Goderich_BCATP_Historical_Plaque.JPG')
        @photo.wikimedia_data
      end
      it 'has a file_url' do
        expect(@photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/Goderich_BCATP_Historical_Plaque.JPG?width=640')
      end
    end
    context 'of a Commons photo wiki page' do
      before do
        @photo = Photo.new(url: 'https://commons.wikimedia.org/wiki/Dog#/media/File:DogDewClawTika1_wb.jpg')
        @photo.wikimedia_data
      end
      it 'has a file_url' do
        expect(@photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/DogDewClawTika1_wb.jpg?width=640')
      end
    end
    context 'a Commons upload photo' do
      before do
        @photo = Photo.new(url: 'https://upload.wikimedia.org/wikipedia/commons/4/49/DogDewClawTika1_wb.jpg')
        @photo.wikimedia_data
      end
      it 'has a file_url' do
        expect(@photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/DogDewClawTika1_wb.jpg?width=640')
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
      before do
        @photo = Photo.new(url: 'https://www.geograph.org.uk/photo/5561265')
       @photo.wikimedia_data
      end
      it 'has a file url' do
        expect(@photo.file_url).to eq('https://s0.geograph.org.uk/geophotos/05/56/12/5561265_bc74db7d.jpg')
      end
    end
  end
#  describe 'setting Flickr data' do
#    context 'of a Flickr photo' do
#      before do
#        @photo = Photo.new(url: 'https://www.flickr.com/photos/josemoya/36584194011/in/album-72157667474637461/')
#        @photo.wikimedia_data
#      end
#      it 'has a file url' do
#        expect(@photo.file_url).to eq('http://farm5.staticflickr.com/4396/36584194011_8178d33349_z.jpg')
#      end
#      it 'has a photo url' do
#        expect(@photo.photo_url).to eq('http://www.flickr.com/photos/josemoya/36584194011/')
#      end
#      it 'has a photographer' do
#        expect(@photo.photographer).to eq('José Moya')
#      end
#      it 'has a photographer url' do
#        expect(@photo.photographer_url).to eq('https://www.flickr.com/photos/josemoya/')
#      end
#      it 'has a licence' do
#        expect(@photo.licence).to be nil
#      end
#    end
#  end
end
