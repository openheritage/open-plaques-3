# control CMS
class PagesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: :show
  before_action :find, only: %i[show edit update]
  respond_to :html, :json

  def about
    @organisations_count = Organisation.count
  end

  def show
    respond_with @page
  end

  def index
    @pages = Page.order(:slug)
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(permitted_params)
    return unless @page.save

    redirect_to pages_path
  end

  def update
    return unless @page.update(permitted_params)

    redirect_to(action: :show, id: @page.slug)
  end

  protected

  def find
    @page = Page.find_by_slug!(params[:id])
  end

  private

  def permitted_params
    params.require(:page).permit(
      :body,
      :name,
      :slug,
      :strapline
    )
  end
end
