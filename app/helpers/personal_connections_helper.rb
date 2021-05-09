# Assist personal connections
module PersonalConnectionsHelper
  def personal_connection_path(personal_connection)
    url_for(controller: 'PersonalConnections', action: :show, id: personal_connection.id, plaque_id: pc.plaque_id)
  end

  def personal_connections_path(plaque)
    url_for(controller: 'PersonalConnections', action: :index, plaque_id: plaque.id)
  end

  def edit_personal_connection_path(personal_connection)
    url_for(controller: 'PersonalConnections', action: :edit, id: personal_connection.id, plaque_id: personal_connection.plaque_id)
  end

  def new_personal_connection_path(plaque)
    url_for(controller: 'PersonalConnections', action: :new, plaque_id: plaque.id)
  end

  # how a person is connected to a plaque
  # TODO order by years and by logical progression (birth, lived at, died at)
  # TODO group multiple instances...e.g. visited (1912, 1914-1916, and 1923)
  def verbs(person, plaque)
    verbs = []
    connections = person.personal_connections.where(plaque_id: plaque)
    connections.each do |personal_connection|
      years = ''
      years += "(#{personal_connection.from}" if personal_connection.from != ''
      years += "-#{personal_connection.to}" unless ['', personal_connection.from].include?(personal_connection.to)
      years += ')' if years != ''
      verbs << "#{personal_connection.verb.name} #{years}"
    end
    verbs
  end
end
