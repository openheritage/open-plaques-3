class ErrorsController < ApplicationController

  def not_found
    raise ActiveRecord::RecordNotFound
  end

end
