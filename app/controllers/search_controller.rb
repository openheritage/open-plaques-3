class SearchController < ApplicationController

  before_filter :set_phrase, :only => [:index, :results]

  def index
    @search_results = []
    if @phrase == nil
      @phrase = ""
    end
    if @phrase != nil && @phrase != ""
      @phrase = @phrase.downcase
      @unaccented_phrase = @phrase.tr("ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")

      @people = Person.where(["lower(name) LIKE ?", "%" + @phrase.gsub(" ","%").gsub(".","%") + "%"])
      @search_results = @people
      # include all that person's plaques
      @people.each do |person|
        @search_results += @person.plaques
      end
      @search_results += Person.where(["lower(aka) LIKE ?", "%" + @phrase.gsub(" ","%").gsub(".","%") + "%"])
      # loop through those people and check for accented names and akas. Do another search for them

      # if the phrase has an accent, check for a non-accented person name
      @search_results += Person.where(["lower(name) LIKE ?", "%" + @unaccented_phrase.gsub(" ","%").gsub(".","%") + "%"])
      @search_results += Plaque.where(["lower(inscription) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @search_results += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}

      @search_results += Plaque.where(["lower(inscription) LIKE ?", "%" + @phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @search_results += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
    elsif  @street != nil && @street !=""
      @search_results = Plaque.find(:all, :conditions => ["lower(address) LIKE ?", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:area => :country]])      
      @phrase = ""
    end
    respond_to do |format|
      format.html
      format.json { render :json => @search_results.uniq }
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
