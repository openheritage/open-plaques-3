class StaticPagesController < ApplicationController
  def about
    @organisations_count = Organisation.count
    render 'about/index'
  end

  def contribute
    render 'contribute/index'
  end

  def contact
    render 'contact/index'
  end

  def data
    render 'data/index'
  end
end
