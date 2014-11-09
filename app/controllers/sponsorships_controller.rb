class SponsorshipsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:new, :index]
  before_filter :find_sponsorship, :only => [:destroy]
  before_filter :list_organisations, :only => [:new, :index]

  respond_to :json

  def destroy

    @sponsorship = Sponsorship.find(params[:id])
    plaque = @sponsorship.plaque

    @sponsorship.destroy

    redirect_to plaque_sponsorships_path(plaque)
  end

  def new
    @sponsorship = @plaque.sponsorships.new
    render 'plaques/sponsorships/new'
  end

  def create
    @plaque = Plaque.find(params[:sponsorship][:plaque_id])
    @sponsorship = @plaque.sponsorships.new(sponsorship_params)
    @sponsorship.save
    redirect_to :back
  end

  def index
    respond_to do |format|
      format.html {
        @sponsorship = @plaque.sponsorships.new
        render 'plaques/sponsorships/new'
      }
      format.json {
        render :json => @plaque.sponsorships.as_json
      }
    end    
  end

  private

  def sponsorship_params
    params.require(:sponsorship).permit(:plaque_id, :organisation_id)
  end


    def find_plaque
      if params[:plaque_id]
        @plaque = Plaque.find(params[:plaque_id])
      end
    end
    
    def find_sponsorship
      if params[:id]
        @sponsorship = Sponsorship.find(params[:id])
      end
    end
    
    def list_organisations
      @organisations = Organisation.order('name')
    end

end
