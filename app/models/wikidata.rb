require 'open-uri'
require 'ostruct'

# Wikidata has structure "entities": {"Q123": { ... }}
# The Q code is unknown to us in advance
class OpenStruct
  def root_key
    @table.keys.first
  end

  def qcode
    self.entities&.root_key&.to_s
  end

  def q
    self.entities&.send("#{qcode}")
  end

  def not_found?
    "-1" == self.qcode
  end

  def disambiguation?
    q&.descriptions&.en&.value&.to_s&.include? "disambiguation page"
  end
end

class Wikidata
  def initialize(wikidata_id)
    return if !wikidata_id&.match(/Q\d*$/)
    @id = wikidata_id
    api = "https://www.wikidata.org/w/api.php?action=wbgetentities&ids=#{@id}&format=json"
    response = open(api)
    resp = response.read
    @wikidata = JSON.parse(resp, object_class: OpenStruct)
  end

  def self.logger
    Rails.logger
  end

  def qcode
    return if !@wikidata || @wikidata.not_found?
    @wikidata.qcode
  end

  def disambiguation?
    return if !@wikidata || @wikidata.not_found?
    @wikidata.disambiguation?
  end

  def not_found?
    @wikidata&.not_found?
  end

  def born_in
    return if !@wikidata || @wikidata.not_found?
    t = @wikidata.q&.claims&.P569&.first&.mainsnak&.datavalue&.value&.time
    # can by +1600-00-00 for 'unknown month and day' which breaks datetime
    t&.match(/\+(\d\d\d\d)/)[1] if t&.match(/\+(\d\d\d\d)/)
  end

  def died_in
    return if !@wikidata || @wikidata.not_found?
    t = @wikidata.q&.claims&.P570&.first&.mainsnak&.datavalue&.value&.time
    t&.match(/\+(\d\d\d\d)/)[1] if t&.match(/\+(\d\d\d\d)/)
  end

  def dates?(born, died)
    (born && born_in ? born_in == born : true) && (died && died_in ? died_in == died : true)
  end

  def self.qcode(term)
    term = term.tr("’ß#ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
"'s AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz")
    api_root = "https://www.wikidata.org/w/api.php?action="
    name_and_dates = term.match /(.*) \((\d\d\d\d)\s*-*\s*(\d\d\d\d)\)/
    if name_and_dates
      name = name_and_dates[1]
      born = name_and_dates[2]
      died = name_and_dates[3]
    else
      name_and_dates = term.match /(.*) \(d.\s*-*\s*(\d\d\d\d)\)/
      if name_and_dates
        name = name_and_dates[1]
        died = name_and_dates[2]
      else
        name_and_dates = term.match /(.*) \(b.\s*-*\s*(\d\d\d\d)\)/
        if name_and_dates
          name = name_and_dates[1]
          born = name_and_dates[2]
        else
          name = term
        end
      end
    end
    begin
      api = "#{api_root}wbgetentities&sites=enwiki&titles=#{name}&format=json"
      logger.debug "#{api}"
      response = open(api)
      resp = response.read
      wikidata = JSON.parse(resp, object_class: OpenStruct)
      if (wikidata.not_found?)
        #  try again with first letter in uppercase
        name = name[0].upcase + name[1..-1]
        api = "#{api_root}wbgetentities&sites=enwiki&titles=#{name}&format=json"
        logger.debug "#{api}"
        response = open(api)
        resp = response.read
        wikidata = JSON.parse(resp, object_class: OpenStruct)
      end
      if (wikidata.not_found? || wikidata.disambiguation?) && (born || died)
        api = "#{api_root}query&list=search&srsearch=#{name}&format=json"
        response = open(api)
        resp = response.read
        search_wikidata = JSON.parse(resp, object_class: OpenStruct)
        search_wikidata.query.search.each do |search_result|
          w = Wikidata.new(search_result.title)
          return w.qcode if w.dates?(born, died)
        end
      end
      if wikidata.not_found? || wikidata.disambiguation?
        nil
      elsif (born || died)
        w = Wikidata.new(wikidata.qcode)
        w.qcode if w.dates?(born, died)
      else
        wikidata.qcode
      end
    rescue URI::InvalidURIError
      logger.error "nasty char in there"
    end
  end

  def en_wikipedia_url
    return if !@wikidata || @wikidata.not_found?
    t = @wikidata&.q&.sitelinks&.enwiki&.title
    "https://en.wikipedia.org/wiki/#{t.gsub(" ","_")}" if t
  end
end
