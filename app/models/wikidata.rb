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
  def self.qcode(term)
    api = "https://www.wikidata.org/w/api.php?action=wbgetentities&sites=enwiki&titles=#{term}&format=json"
    response = open(api)
    resp = response.read
    wikidata = JSON.parse(resp, object_class: OpenStruct)
    wikidata.not_found? || wikidata.disambiguation? ? nil : wikidata.qcode
  end

  def self.en_wikipedia_url(wikidata_id)
    return if !wikidata_id || !wikidata_id.match(/Q\d*$/)
    api = "https://www.wikidata.org/w/api.php?action=wbgetentities&ids=#{wikidata_id}&format=json&props=sitelinks&sitefilter=enwiki"
    response = open(api)
    resp = response.read
    parsed_json = JSON.parse(resp)
    begin
      t = parsed_json['entities']["#{wikidata_id}"]['sitelinks']['enwiki']['title']
      return "https://en.wikipedia.org/wiki/#{t.gsub(" ","_")}"
    rescue
    end
  end
end
