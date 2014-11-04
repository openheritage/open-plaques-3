class SearchController < ApplicationController

  before_filter :set_phrase, :only => [:index, :results]

  def index
    @search_results = []
    if @phrase == nil
      @phrase = ""
    end
    if @phrase != nil && @phrase != ""
      if @street != nil && @street !=""
        @search_results = Plaque.find(:all, :joins => :location, :conditions => ["lower(inscription) LIKE ? and lower(locations.name) LIKE ?", "%" + @phrase.downcase + "%", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])
      else
        @search_results = Person.find(:all, :conditions => ["lower(name) LIKE ?", "%" + @phrase.downcase.gsub(" ","%").gsub(".","%") + "%"])
        @search_results += Plaque.find(:all, :conditions => ["lower(inscription) LIKE ?", "%" + @phrase.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]]).sort!{|t1,t2|t1.to_s <=> t2.to_s}
        @search_results += Plaque.find(:all, :conditions => ["lower(inscription_in_english) LIKE ?", "%" + @phrase.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]]).sort!{|t1,t2|t1.to_s <=> t2.to_s}
      end
    elsif  @street != nil && @street !=""
      @search_results = Plaque.find(:all, :joins => :location, :conditions => ["lower(locations.name) LIKE ?", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])      
      @phrase = ""
    end
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml # { render :xml => @search_results }
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
