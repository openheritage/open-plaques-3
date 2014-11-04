class VerbsController < ApplicationController

  before_filter :authenticate_admin!, :only => [:destroy]
  before_filter :authenticate_user!, :except => [:index]

  def index
    @verbs = Verb.find(:all, :order => :name)
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @verbs }
    end
  end

  def show
    @verb = Verb.find_by_name(params[:id].gsub('_',' '))
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @verb }
    end
  end

  def new
    @verb = Verb.new
  end

  def create
    @verb = Verb.new(params[:verb])
    if @verb.save
      redirect_to verb_path(@verb)
    else
      render :new
    end
  end

  # DELETE /verbs/1
  def destroy
    @verb = Verb.find params[:id]
    @verb.destroy
    redirect_to verbs_path
  end

end
