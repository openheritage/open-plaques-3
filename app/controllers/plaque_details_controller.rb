class PlaqueDetailsController < ApplicationController

  before_action :find, only: [:edit,:show]

  protected

    def find
      @plaque = Plaque.find(params[:plaque_id])
    end
end
