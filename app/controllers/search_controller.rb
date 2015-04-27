class SearchController < ApplicationController

  before_filter :set_phrase, :only => [:index, :results]

  def index
    @search_results = []
    if @phrase == nil
      @phrase = ""
    end
    if @phrase != nil && @phrase != ""
      @search_results = Person.where(["lower(name) LIKE ?", "%" + @phrase.downcase.gsub(" ","%").gsub(".","%") + "%"])
      @search_results += Plaque.where(["lower(inscription) LIKE ?", "%" + @phrase.downcase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @search_results += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @phrase.downcase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
    elsif  @street != nil && @street !=""
      @search_results = Plaque.find(:all, :conditions => ["lower(address) LIKE ?", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:area => :country]])      
      @phrase = ""
    end
    respond_to do |format|
      format.html
      format.json { render :json => @search_results }
    end
  end

  def get_search_results(phrase)
  end

  protected

    def set_phrase
      @phrase = params[:phrase]
      @street = params[:street]
      @street = @street[/([a-zA-Z][a-z A-Z]+)/] unless @street == nil
    end

end
