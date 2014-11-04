require 'open-uri'
require "rexml/document"
include REXML

class PlaqueGeolocationController < ApplicationController

  before_filter :authenticate_user!

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @geocodes = Array.new
    unless @plaque.geolocated?
      @geocodes = geocode_from_flickr
    end
    render 'plaques/geolocation/edit'
  end

  private

  def geocode_from_flickr
    geocodes = Array.new
    begin
      response = open(get_flickr_api_url(params[:plaque_id], true))
      doc = REXML::Document.new(response.read)
      doc.elements.each('//rsp/photos/photo') do |photo|
        if photo.attributes["latitude"] != nil && photo.attributes["latitude"] != "0"
          geocodes.push [photo.attributes["latitude"], photo.attributes["longitude"], photo.attributes["ownername"]]
        end
      end
    rescue
    end
    return geocodes
  end

end