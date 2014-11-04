class PlaqueTalkController < ApplicationController

  respond_to :json

  def create
  	puts 'digame?'
  	@plaque = Plaque.find(params[:plaque_id])
    puts @plaque
    puts params[:message] + ' from ' + params[:from]
    render :json => { 'reply' => 'thank you' }, :status => :ok
  end

end