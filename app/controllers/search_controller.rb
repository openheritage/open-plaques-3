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
      # check people first
      @people =  Person.where(["lower(name) LIKE ?", "%" + @phrase.gsub(" ","%").gsub(".","%") + "%"])
      @people += Person.where(["lower(name) LIKE ?", "%" + @unaccented_phrase.gsub(" ","%").gsub(".","%") + "%"]) if @phrase.match(/[À-ž]/)
      @people += Person.where(["lower(array_to_string(aka, ' ')) LIKE ?", "%" + @phrase.gsub(" ","%").gsub(".","%") + "%"])

      @search_results = @people.uniq
      # if the phrase has an accent, check for a non-accented person name
      @plaques = Plaque.where(["lower(inscription) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s} if @phrase.match(/[À-ž]/)
      @plaques += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s} if @phrase.match(/[À-ž]/)
      @plaques += Plaque.where(["lower(inscription) LIKE ?", "%" + @phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @plaques += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @phrase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      # include all that person's plaques
      @people.each do |person|
        @plaques += person.plaques
      end
      # Look for their akas in the inscription
      @people.each do |person|
        person.aka.each do |aka|
          @plaques += Plaque.where(["lower(inscription) LIKE ?", "%" + aka.downcase + "%"]).includes([[:personal_connections => [:person]], [:area => :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
        end
      end

      @search_results += @plaques.uniq
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
