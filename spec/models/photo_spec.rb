require 'spec_helper'

describe Photo do

  describe '#title' do
    context 'a photo' do
      before do
        @photo = Photo.new
      end
      it 'has a title' do
        expect(@photo.title).to eq('a photo')
      end
    end
    context 'a photo with an id' do
      before do
        @photo = Photo.new(id: 2300)
      end
      it 'has a title' do
        expect(@photo.title).to eq('photo № 2300')
      end
    end
    context 'a photo of a plaque' do
      before do
        @photo = Photo.new
        @photo.plaque = Plaque.new
      end
      it 'has a title' do
        expect(@photo.title).to eq('a photo of a plaque')
      end
    end
    context 'a photo of a person' do
      before do
        @photo = Photo.new
        @person = Person.new
        @photo.person = @person
      end
      it 'has a title' do
        expect(@photo.title).to eq('a photo of ')
      end
    end
  end

  describe '#attribution' do
    context 'a photo' do
      before do
        @photo = Photo.new()
      end
      it 'is copyright on the web' do
        expect(@photo.attribution).to eq('&copy;  on the web')
      end
    end

    context 'a Commons photo' do
      before do
        @photo = Photo.new(url: 'https://commons.wikimedia.org/wiki/File:Goderich_BCATP_Historical_Plaque.JPG')
        @photo.wikimedia_data
      end
      it 'includes a commons licence statement' do
        expect(@photo.attribution).to eq('&copy; SteveTheAirman on Wikimedia Commons CC BY-SA 3.0')
      end
    end
  end

  describe '#wikimedia_data' do
    context 'a Commons photo' do
      before do
        @photo = Photo.new(url: 'https://commons.wikimedia.org/wiki/File:Goderich_BCATP_Historical_Plaque.JPG')
        @photo.wikimedia_data
      end
      it 'has a file_url' do
        expect(@photo.file_url).to eq('https://commons.wikimedia.org/wiki/Special:FilePath/Goderich_BCATP_Historical_Plaque.JPG?width=640')
      end
    end
    context 'a Commons photo' do
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
      it 'has no file_url' do
        expect(@photo.file_url).to eq(nil)
      end
    end
  end

end