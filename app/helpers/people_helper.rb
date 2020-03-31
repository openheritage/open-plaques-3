# Assist People
module PeopleHelper
  def roles_list(person)
    list = []
    list << person.type if person.roles.empty? || person.type != 'man'
    person.straight_roles.each { |personal_role| list << dated_role(personal_role) }
    person.relationships.each { |relationship| list << link_to(relationship.role.name, relationship.role) } if person.inanimate_object?
    list.uniq!
    content_tag(:span, list.to_sentence.html_safe, { id: "person-#{person.id}-roles" })
  end

  def dated_role(personal_role)
    r = ''
    if personal_role.ordinal
      r += personal_role.ordinal.ordinalize
      r += ' '
    end
    r += link_to(personal_role.role.name, role_path(personal_role.role), class: 'role')
    if personal_role.related_person
      r += ' of '
      r += link_to(personal_role.related_person.name, personal_role.related_person)
    end
    if personal_role.started_at? && personal_role.ended_at?
      r += ' ('
      r += personal_role.started_at.year.to_s
      if personal_role.started_at != personal_role.ended_at
        r += '-'
        r += personal_role.ended_at.year.to_s
      end
      r += ')'
    elsif personal_role.started_at?
      r += " (from #{personal_role.started_at.year})"
    elsif personal_role.ended_at?
      r += " (until #{personal_role.ended_at.year})"
    end
    r
  end

  # select the very first html paragraph
  def wikipedia_summary(url)
    doc = Nokogiri::HTML(URI.parse(url).open)
    first_para_html = doc.search('//p').first.to_s # .gsub(/<\/?[^>]*>/, "")
    Sanitize.clean(first_para_html)
  rescue Exception
    nil
  end

  def dated_roled_person(person)
    return 'XXXX' unless person

    roles = []
    person.personal_roles.each { |personal_role| roles << dated_role(personal_role) }
    dated_person(person) + roles.empty? ? '' : ', ' + roles.to_sentence.html_safe
  end

  def dated_person(person, options = {})
    dates = ' '
    dates += person.dates if person.dates
    return content_tag(:span, person.full_name, { class: :fn, property: 'rdfs:label foaf:name vcard:fn' }) + dates.html_safe if options[:links] == :none

    link_to(person.full_name, person, { class: 'fn url', property: 'rdfs:label foaf:name vcard:fn', rel: 'foaf:homepage vcard:url' }) + dates.html_safe
  end
end
