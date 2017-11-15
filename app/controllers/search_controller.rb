class SearchController < ApplicationController

  def index
    @search_results = []
    @original_phrase = params[:phrase]
    @phrase = @original_phrase
    @phrase = "" if @phrase == nil
    @people = []
    @places = []
    @plaques = []
    if @phrase != ""
      cap = 20 # to protect from stupid searches like "%a%"
      unaccented_phrase = @phrase.tr("’ßÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"'sAAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
      full_phrase_like = "%#{@phrase}%"
      phrase_like = "%#{@phrase.tr(" ","%").tr(".","%")}%"
      unaccented_phrase_like = "%#{unaccented_phrase.tr(" ","%").tr(".","%")}%"

      @people += Person.where(["name ILIKE ?", full_phrase_like]).limit(cap)
      @people += Person.where(["name ILIKE ?", phrase_like]).limit(cap)
      @people += Person.where(["name ILIKE ?", unaccented_phrase_like]).limit(cap) if @phrase.match(/[À-ž]/)
      @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", full_phrase_like]).limit(cap)
      @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", phrase_like]).limit(cap)
      @people += Person.where(["array_to_string(aka, ' ') ILIKE ?", unaccented_phrase_like]).limit(cap) if @phrase.match(/[À-ž]/)

      @places += Area.where(["name ILIKE ?", phrase_like]).limit(cap)

      @plaques += Plaque.where(["inscription ILIKE ?", full_phrase_like]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @plaques += Plaque.where(["inscription ILIKE ?", phrase_like]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @plaques += Plaque.where(["inscription_in_english ILIKE ?", phrase_like]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      if @phrase.match(/[À-ž]/)
        @plaques += Plaque.where(["inscription ILIKE ?", unaccented_phrase_like]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
        @plaques += Plaque.where(["inscription_in_english ILIKE ?", unaccented_phrase_like]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      end
      # include all that person's plaques
      @people.each do |person|
        @plaques += person.plaques
      end
      # Look for their akas in the inscription
      @people.each do |person|
        person.aka.each do |aka|
          @plaques += Plaque.where(["inscription ILIKE ?", "%#{aka}%"]).limit(cap).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
        end
      end
      @people.uniq!
      @places.uniq!
      @plaques.uniq!
      @search_results += @people
      @search_results += @places
      @search_results += @plaques
    end

    respond_to do |format|
      format.html
      format.json { render json: @search_results.uniq }
      format.geojson { render geojson: @search_results.uniq }
    end
  end

end
