require 'open-uri'
require 'ostruct'

# Wikidata has structure "entities": {"Q123": { ... }}
# The Q code is unknown to us in advance
class OpenStruct
  def root_key
    @table.keys.first
  end

  def qcode
    self.entities.root_key.to_s
  end

  def q
    self.entities.send("#{qcode}")
  end

  def not_found?
    self.qcode == '-1'
  end

  def disambiguation?
    q.descriptions&.en&.value&.to_s == "Wikimedia disambiguation page"
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

  def born_in
    return if !@wikidata
    t = @wikidata.q&.claims&.P569&.first&.mainsnak&.datavalue&.value&.time
    datetime = t.to_time
    datetime.strftime("%Y")
  end

  def died_in
    t = @wikidata.q&.claims&.P570&.first&.mainsnak&.datavalue&.value&.time
    datetime = t.to_time
    datetime.strftime("%Y")
  end

  def self.qcode(term)
    api = "https://www.wikidata.org/w/api.php?action=wbgetentities&sites=enwiki&titles=#{term}&format=json"
    response = open(api)
    resp = response.read
    wikidata = JSON.parse(resp, object_class: OpenStruct)
    wikidata.not_found? || wikidata.disambiguation? ? nil : wikidata.qcode
  end

  def en_wikipedia_url
    return if !@wikidata
    t = @wikidata&.q&.sitelinks&.enwiki&.title
    "https://en.wikipedia.org/wiki/#{t.gsub(" ","_")}"
  end
end
