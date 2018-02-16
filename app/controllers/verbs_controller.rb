class VerbsController < ApplicationController

  before_action :authenticate_user!, except: [:index]

  def index
    @verbs = Verb.order(personal_connections_count: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @verbs }
    end
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    @verbs = "{}"
    @verbs = Verb.select(:id,:name)
      .name_contains(params[:contains])
      .limit(limit) if params[:contains]
    @verbs = Verb.select(:id,:name)
      .name_starts_with(params[:starts_with])
      .limit(limit) if params[:starts_with]
    render json: @verbs.as_json(
      only: [:id, :name]
    )
  end

  def show
    @verb = Verb.find_by_name(params[:id].tr('_',' '))
    @personal_connections = @verb.personal_connections.paginate(page: params[:page], per_page: 50)
    respond_to do |format|
      format.html
      format.json { render json: @verb }
    end
  end

  def new
    @verb = Verb.new
  end

  def create
    @verb = Verb.new(verb_params)
    if @verb.save
      redirect_to verb_path(@verb)
    else
      render :new
    end
  end

  private

    def verb_params
      params.require(:verb).permit(
        :name,
      )
    end

end
