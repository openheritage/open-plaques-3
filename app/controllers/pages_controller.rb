class PagesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:show]

  before_filter :find_page, :only => [:show, :edit, :update]

  respond_to :html, :json

  def about
    @organisations_count = Organisation.count
  end

  def show
    respond_with(@page)
  end

  def index
    @pages = Page.all(:order => :slug)
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])

    if @page.save
      redirect_to pages_path
    end

  end

  def update
    if @page.update_attributes(params[:page])
      redirect_to :action => :show, :id => @page.slug
    end
  end

  protected

    def find_page
      @page = Page.find_by_slug!(params[:id])
    end

end