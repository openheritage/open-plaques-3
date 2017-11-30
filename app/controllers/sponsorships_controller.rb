class SponsorshipsController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: [:destroy]
  before_action :list_organisations, only: [:new, :index]

  def destroy
    plaque = @sponsorship.plaque
    @sponsorship.destroy
    redirect_to plaque_sponsorships_path(plaque)
  end

  def new
    @plaque = Plaque.find(params[:plaque_id])
    @sponsorship = @plaque.sponsorships.new
    render 'plaques/sponsorships/new'
  end

  def create
    @plaque = Plaque.find(params[:sponsorship][:plaque_id])
    @sponsorship = @plaque.sponsorships.new(sponsorship_params)
    @sponsorship.save
    redirect_back(fallback_location: root_path)
  end

  def index
    new
  end

  private

    def sponsorship_params
      params.require(:sponsorship).permit(:plaque_id, :organisation_id)
    end

    def find
      if params[:id]
        @sponsorship = Sponsorship.find(params[:id])
      end
    end

    def list_organisations
      @organisations = Organisation.select(:id, :name).order('name')
    end

end
