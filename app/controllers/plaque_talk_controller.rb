class PlaqueTalkController < PlaqueDetailsController

  respond_to :json

  def create
    puts params[:message] + ' from ' + params[:from]
    render json: { 'reply' => 'thank you' }, status: :ok
  end

end
