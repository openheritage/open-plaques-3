class PlaqueDetailsController < ApplicationController

  before_filter :find, :only => [:edit]

  protected
  
    def find
      @plaque = Plaque.find(params[:plaque_id])
    end
end
