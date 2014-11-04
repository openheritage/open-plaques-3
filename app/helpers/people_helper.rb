# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'sanitize'

module PeopleHelper

  def roles_list(person)
    if person.roles.size > 0
      list = [person.type]
      person.straight_roles.each do |personal_role|
        list <<  dated_role(personal_role)
      end
      content_tag("p", list.to_sentence.html_safe, {:class => "roles"})
    end
  end

  def dated_role(personal_role)
    r = ""
    if personal_role.ordinal
      r += personal_role.ordinal.ordinalize + " "
    end
    r += link_to(personal_role.role.name, role_path(personal_role.role), :class => "role")
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

  def dates(person)
    dates = ""
    if person.born_on
      dates = "("
      if person.born_on_is_circa
        dates += circa_tag
      end
      dates += person.born_in.to_s
      if person.died_on && (person.born_in != person.died_on)
        dates += "-" + person.died_in.to_s
      else
        dates += "-present"
      end
      dates += ")"
    end
  end

  def dbpedia_url(person)
    unless person.dbpedia_url.empty?
      dbpedia_url
    else
      person.default_wikipedia_url.gsub(/[a-zA-Z]{0,2}\.wikipedia\.org\/wiki\//, "dbpedia.org/resource/")
    end
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
  #    options.stringify_keys!
      if (person.born_on? and person.died_on? and (person.born_on == person.died_on))
        dates = " (" + linked_birth_date(person) + ")"
      elsif (person.born_on? and person.died_on?)
        dates = " (" + linked_birth_date(person) + "&#8202;–&#8202;" + linked_death_date(person) + ")"
      elsif (person.born_on?)
        dates = " (" + person.creation_word + " "
        dates += linked_birth_date(person) + "<span property=\"foaf:age\" content=\"#{person.age}\" />)"
      elsif (person.died_on?)
        if (person.thing?)
          dates = " (to " + linked_death_date(person) + ")"
        elsif (person.group?)
          dates = " (to " + linked_death_date(person) + ")"
        elsif (person.place?)
          dates = " (to " + linked_death_date(person) + ")"
        else
          dates = " (died " + linked_death_date(person) + ")"
        end
      else
        dates =""
      end
      if options[:links] == :none
        return content_tag("span", person.full_name, {:class => "fn", :property => "rdfs:label foaf:name vcard:fn"}) + dates.html_safe
      else
        return link_to(person.full_name, person, {:class => "fn url", :property => "rdfs:label foaf:name vcard:fn", :rel => "foaf:homepage vcard:url"}) + dates.html_safe
      end
    end

    def linked_death_date(person)
      birth_date = ""
      if person.died_on
        if person.died_on_is_circa
          birth_date = circa_tag
        end
        birth_date += link_to(person.died_in.to_s, people_alive_in_path(person.died_in.to_s), {:about => "/people/#{person.id}#person", :property => "dbpprop:dateOfDeath", :datatype => "xsd:date", :content => person.died_in.to_s})
      end
    end

    def linked_birth_date(person)
      birth_date = ""
      if person.born_on
        if person.born_on_is_circa
          birth_date = circa_tag
        end
        birth_date += link_to(person.born_in.to_s, people_alive_in_path(person.born_in.to_s), {:class => "bday", :about => "/people/#{person.id}#person", :property => "dbpprop:dateOfBirth vcard:bday", :datatype => "xsd:date", :content => person.born_in.to_s})
      end
    end

    def verbs(person, plaque)
      verbs = Array.new
      connections = person.personal_connections.where(:plaque_id => plaque)
      connections.each do |personal_connection|
        years = ""
        if personal_connection.from != ""
          years += "(" + personal_connection.from
        end
        if personal_connection.to != "" and personal_connection.to != personal_connection.from
          years += "-" + personal_connection.to
        end
        if years != ""
          years += ")"
        end
        verbs << personal_connection.verb.name + " " + years
      end
      verbs
    end
	
	def age_icon(age)
	  if age < 3
	    image_tag("age1.png", {:alt => "first age of man"})
      elsif age < 10
	    image_tag("age2.png", {:alt => "second age of man"})
      elsif age < 20
	    image_tag("age3.png", {:alt => "third age of man"})
      elsif age < 30
	    image_tag("age4.png", {:alt => "fourth age of man"})
      elsif age < 40
	    image_tag("age5.png", {:alt => "fifth age of man"})
      elsif age < 50
	    image_tag("age6.png", {:alt => "sixth age of man"})
      elsif age < 60
	    image_tag("age7.png", {:alt => "seventh age of man"})
      elsif age < 70
	    image_tag("age8.png", {:alt => "eigth age of man"})
      elsif age < 80
	    image_tag("age9.png", {:alt => "ninth age of man"})
      elsif age < 90
	    image_tag("age10.png", {:alt => "tenth age of man"})
      else
	    image_tag("age11.png", {:alt => "eleventh age of man"})
	  end
	end

end
