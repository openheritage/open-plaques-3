class StaticPagesController < ApplicationController
  def about
    @organisations_count = Organisation.count
    render 'about/index'
  end

  def contribute
    render 'contribute/show'
  end

  def contact
    render 'contact/show'
  end
end