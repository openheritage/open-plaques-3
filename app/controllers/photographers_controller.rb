class PhotographersController < ApplicationController

  def index
    @photographers_count = Photographer.all.count
    @photographers = Photographer.top50
    description = 'Photographers of blue plaques'
    set_meta_tags noindex: true
    set_meta_tags description: description
      set_meta_tags open_graph: {
        type: :website,
        url: url_for(only_path: false),
        title: 'Plaque hunters',
        description: description,
      }
      set_meta_tags twitter: {
        card: 'summary_large_image',
        site: '@openplaques',
        title: description,
      }
    respond_to do |format|
      format.html
      format.json { render json: @photographers }
    end
  end

  def show
    @photographer = Photographer.new
    @photographer.id = params[:id].gsub(/\_/,'.')
    set_meta_tags nofollow: true
    respond_to do |format|
      format.html
      format.json { render json: @photographer }
    end
  end

  def new
  end

  def create
    # photographer isn't an actual object, but we can search a named Flickr user's photos
    # which is useful, because it finds more than is in the public search
    @photographer = params[:flickr_url]
    @photographer.gsub!('http://www.flickr.com/photos/','')
    @photographer.gsub!(/\/.*/,'')
    Helper.instance.find_photo_by_machinetag(nil, @photographer)
    redirect_to photographers_path
  end

  protected

    class Helper
      include Singleton
      include PlaquesHelper
    end

end
