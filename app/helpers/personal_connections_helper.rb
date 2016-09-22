module PersonalConnectionsHelper

  def personal_connection_path(pc)
    url_for(controller: "PersonalConnections", action: :show, id: pc.id, plaque_id: pc.plaque_id)
  end

  def personal_connections_path(plaque)
    url_for(controller: "PersonalConnections", action: :index, plaque_id: plaque.id)
  end

  def edit_personal_connection_path(pc)
    url_for(controller: "PersonalConnections", action: :edit, id: pc.id, plaque_id: pc.plaque_id)
  end

  def new_personal_connection_path(plaque)
    url_for(controller: "PersonalConnections", action: :new, plaque_id: plaque.id)
  end

  # how a person is connected to a plaque
  #TODO order by years and by logical progression (birth, lived at, died at)
  #TODO group multiple instances...e.g. visited (1912, 1914-1916, and 1923)
  def verbs(person, plaque)
    verbs = Array.new
    connections = person.personal_connections.where(plaque_id: plaque)
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

end
