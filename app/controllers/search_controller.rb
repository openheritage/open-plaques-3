class SearchController < ApplicationController

  def index
    @phrase = params[:phrase]
    @search_results = []
    @phrase = "" if @phrase == nil
    if @phrase != ""
      @phrase = @phrase.downcase
      @unaccented_phrase = @phrase.tr("ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")

      @people =  Person.where(["lower(name) LIKE ?", "%" + @phrase.tr(" ","%").tr(".","%") + "%"])
      @people += Person.where(["lower(name) LIKE ?", "%" + @unaccented_phrase.tr(" ","%").tr(".","%") + "%"]) if @phrase.match(/[À-ž]/)
      @people += Person.where(["lower(array_to_string(aka, ' ')) LIKE ?", "%" + @phrase.tr(" ","%").tr(".","%") + "%"])

      @places = Area.where(["lower(name) LIKE ?", "%" + @phrase.tr(" ","%").tr(".","%") + "%"])
      @places.uniq!

      @plaques = Plaque.where(["lower(inscription) LIKE ?", "%" + @phrase + "%"]).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      @plaques += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @phrase + "%"]).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      if @phrase.match(/[À-ž]/)
        @plaques += Plaque.where(["lower(inscription) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
        @plaques += Plaque.where(["lower(inscription_in_english) LIKE ?", "%" + @unaccented_phrase + "%"]).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
      end
      # include all that person's plaques
      @people.each do |person|
        @plaques += person.plaques
      end
      # Look for their akas in the inscription
      @people.each do |person|
        person.aka.each do |aka|
          @plaques += Plaque.where(["lower(inscription) LIKE ?", "%" + aka.downcase + "%"]).includes([[personal_connections: [:person]], [area: :country]]).to_a.sort!{|t1,t2|t1.to_s <=> t2.to_s}
        end
      end

    end
    @people.uniq!
    @places.uniq!
    @plaques.uniq!
    @search_results += @people
    @search_results += @places
    @search_results += @plaques
    respond_to do |format|
      format.html
      format.json { render json: @search_results.uniq }
      format.geojson { render geojson: @search_results.uniq }
    end
  end

end
