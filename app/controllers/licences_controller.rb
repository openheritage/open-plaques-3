class LicencesController < ApplicationController

  def index
    @licences = Licence.all
    @licences = @licences.sort_by { |p| 1 - p.photos.count }
    set_meta_tags noindex: true
    set_meta_tags open_graph: {
      type: :website,
      url: url_for(only_path: false),
      title: 'Plaque photo licences',
      description: 'Licences used for photos of historical plaques and markers',
    }
    set_meta_tags twitter: {
      card: 'summary_large_image',
      site: '@openplaques',
      title: 'Licences used for photos of historical plaques and markers',
    }
    respond_to do |format|
      format.html
      format.json { render json: @licences }
    end
  end

end
