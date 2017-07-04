# -*- encoding : utf-8 -*-
#require 'nokogiri'
#require 'sanitize'

module PeopleHelper

  def roles_list(person)
    list = []
    if person.roles.size == 0 || person.type != 'man'
      list << person.type
    end
    person.straight_roles.each do |personal_role|
      list <<  dated_role(personal_role)
    end
    if person.inanimate_object?
      person.relationships.each do |relationship|
        list << link_to(relationship.role.name, relationship.role)
      end
    end
    list.uniq!
    content_tag("span", list.to_sentence.html_safe, {id: "person-" + person.id.to_s + "-roles"})
  end

  def dated_role(personal_role)
    r = ""
    if personal_role.ordinal
      r += personal_role.ordinal.ordinalize + " "
    end
    r += link_to(personal_role.role.name, role_path(personal_role.role), class: "role")
    if personal_role.related_person
      r += " of "
      r += link_to(personal_role.related_person.name, personal_role.related_person)
    end
    if personal_role.started_at? && personal_role.ended_at?
      r += " (" + personal_role.started_at.year.to_s
      if personal_role.started_at != personal_role.ended_at
        r += "-" + personal_role.ended_at.year.to_s
      end
      r += ")"
    elsif personal_role.started_at?
      r += " (from " + personal_role.started_at.year.to_s + ")"
    elsif personal_role.ended_at?
      r += " (until " + personal_role.ended_at.year.to_s + ")"
    end
    return r
  end

  # select the very first html paragraph
  def wikipedia_summary(url)
    doc = Nokogiri::HTML(open(url))
    first_para_html = doc.search('//p').first.to_s # .gsub(/<\/?[^>]*>/, "")
    return Sanitize.clean(first_para_html)
    rescue Exception
    return nil
  end

  # select html paragraphs from a web page given an Array, String or integer
  # e.g. "http://en.wikipedia.org/wiki/Arthur_Onslow", "2,4,5"
  # e.g. "http://en.wikipedia.org/wiki/Arthur_Onslow", "2 4 5"
  # e.g. "http://en.wikipedia.org/wiki/Arthur_Onslow", [2,4,5]
  # e.g. "http://en.wikipedia.org/wiki/Arthur_Onslow", 2
  def wikipedia_summary_each(url, para_numbers)
    if !para_numbers.kind_of?(Array)
      para_numbers = para_numbers.to_s.scan( /\d+/ )
    end
    doc = Hpricot open(url)
    section = para_numbers.inject("") do |para, para_number|
      para += doc.at("p["+para_number.to_s+"]").to_html.gsub(/<\/?[^>]*>/, "") + " "
    end
    return section.strip
    rescue Exception
    return nil
  end

  def dated_roled_person(person)
    if person
      roles = Array.new
      person.personal_roles.each do |personal_role|
        roles << dated_role(personal_role)
      end
      if roles.size > 0
        return dated_person(person) + ", " + roles.to_sentence.html_safe
      else
        return dated_person(person)
      end
    else
      return "XXXX"
    end
  end

  def dated_person(person, options = {})
    dates = " "
    dates += person.dates if person.dates
    if options[:links] == :none
      return content_tag("span", person.full_name, {class: "fn", property: "rdfs:label foaf:name vcard:fn"}) + dates.html_safe
    else
      return link_to(person.full_name, person, {class: "fn url", property: "rdfs:label foaf:name vcard:fn", rel: "foaf:homepage vcard:url"}) + dates.html_safe
    end
  end

  #TODO helper for people_alive_in(year)
  def datespan year
    ran = rand 3
    puts 'random = ' + ran.to_s
    if ran == 0
      '<div class="col-sm-5"><hr/></div>
      <div class="col-sm-5"></div>'
    elsif ran == 1
        '<div class="col-sm-2"></div>
        <div class="col-sm-4"><hr/></div>
        <div class="col-sm-4"></div>'
    else
      '<div class="col-sm-3"></div>
      <div class="col-sm-5"><hr/></div>
      <div class="col-sm-2"></div>'
    end
  end

end
