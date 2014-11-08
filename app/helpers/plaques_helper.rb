require 'open-uri'
require 'net/http'
require 'uri'
require 'rexml/document'

module PlaquesHelper

  def marked_text(text, term)
    text.to_s.gsub(/(#{term})/i, '<mark>\1</mark>').html_safe
  end

  def search_snippet(text, search_term)
    regex = /#{search_term}/i
    if text =~ regex
      text = " " + text + " "  #HACK: This is so there's a space before the first word.
      indexes = []
      first_index = text.index(regex)
      indexes << first_index
      second_index = text.index(regex, (first_index + search_term.length + 50))
      indexes << second_index if second_index
      snippet = ""
      indexes.each do |i|
        i = i - 80
        i = 0 if i < 0
        s = text[i, 160]
        first_space = (s.index(/\s/) + 1)
        last_space = (s.rindex(/\s/) - 1)
        snippet += "..." if i > 0
        snippet += (s[first_space..last_space])
        snippet += "..." if last_space + 2 < text.length
      end
      snippet
    else
      return text
    end
  end

  def kml(plaque, xml)
    if plaque.geolocated?
      xml.Placemark do
        xml.name(plaque.title)
        xml.description do
          xml.cdata!(("<p>" + plaque.inscription + "</p> <p><a href=\"" + plaque_url(plaque) + "\">" + thumbnail_img(plaque) + "</a></p>").html_safe)
        end
        if plaque.latitude && plaque.longitude
          xml.Point do
            xml.coordinates plaque.longitude.to_s + ',' + plaque.latitude.to_s + ",0"
          end
        end
        if plaque.colour && plaque.colour.slug =~ /(blue|black|yellow|red|white|green)/
          xml.styleUrl "#plaque-" + plaque.colour.slug
        else
          xml.styleUrl "#plaque-blue"
        end
      end
    end
  end

  # pass null to search all machinetagged photos on Flickr
  def find_photo_by_machinetag(plaque, flickr_user_id)
#    key = FLICKR_KEY # "86c115028094a06ed5cd19cfe72e8f8b"
    key = "86c115028094a06ed5cd19cfe72e8f8b"
    content_type = "1" # Photos only
    machine_tag_key = "openplaques:id=".to_s
    if (plaque)
      machine_tag_key += plaque.id.to_s
    end

    flickr_url = "https://api.flickr.com/services/rest/"
    method = "flickr.photos.search"
    license = "1,2,3,4,5,6,7" # All the CC licencses that allow commercial re-use

    20.times do |page|

      url = flickr_url + "?api_key=" + key + "&method=" + method + "&page=" + page.to_s + "&license=" + license + "&content_type=" + content_type + "&machine_tags=" + machine_tag_key +  "&extras=date_taken,owner_name,license,geo,machine_tags"

      if (flickr_user_id)
        url += "&user_id=" + flickr_user_id
      end
      puts url

      new_photos_count = 0
      response = open(url)
      doc = REXML::Document.new(response.read)
      doc.elements.each('//rsp/photos/photo') do |photo|
        print "."
        $stdout.flush

        @photo = nil

        file_url = "http://farm" + photo.attributes["farm"] + ".staticflickr.com/" + photo.attributes["server"] + "/" + photo.attributes["id"] + "_" + photo.attributes["secret"] + "_z.jpg"
        photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/" + photo.attributes["id"] + "/"

        @photo = Photo.find_by_url(photo_url)

        if @photo
        else
          plaque_id = photo.attributes["machine_tags"][/openplaques\:id\=(\d+)/, 1]

          puts photo.attributes["title"]

          @plaque = Plaque.find(:first, :conditions => {:id => plaque_id})
          if @plaque
            @photo = Photo.new
            @photo.plaque = @plaque
            @photo.file_url = file_url
            @photo.url = photo_url
            @photo.taken_at = photo.attributes["datetaken"]
            @photo.photographer_url = photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/"
            @photo.photographer = photo.attributes["ownername"]
            if photo.attributes["license"] == "4"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by/2.0/")
            elsif photo.attributes["license"] == "6"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nd/2.0/")
            elsif photo.attributes["license"] == "3"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc-nd/2.0/")
            elsif photo.attributes["license"] == "2"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc/2.0/")
            elsif photo.attributes["license"] == "1"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc-sa/2.0/")
            elsif photo.attributes["license"] == "5"
              @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-sa/2.0/")
            elsif photo.attributes["license"] == "7"
              @photo.licence = Licence.find_by_url("http://www.flickr.com/commons/usage/")
            elsif photo.attributes["license"] == "0"
              @photo.licence = Licence.find_by_url("http://en.wikipedia.org/wiki/All_rights_reserved/")
            else
              puts "Couldn't find license"
            end
            if @photo.save
              new_photos_count += 1
              puts "New photo found and saved"
            else
#            puts "Error saving photo" + @photo.errors.each_full{|msg| puts msg }
            end

            if photo.attributes["latitude"] != "0" && photo.attributes["longitude"] != "0" && !@plaque.geolocated?
              puts "New geolocation found"
              @plaque.latitude = photo.attributes["latitude"]
              @plaque.longitude = photo.attributes["longitude"]
              if @plaque.save
                puts "New geolocation added to photo"
              else
                puts "Error adding geolocation to photo" + plaque.errors.full_messages.to_s #methods.join(" ")
              end
            end
          else
            puts "Photo's machine tag doesn't match a plaque."
          end
        end
      end
    end
  end

    # pass null to search all photos on Flickr
    def crawl_flickr(group_id='74191472@N00')
    
      key = "86c115028094a06ed5cd19cfe72e8f8b" # FLICKR_KEY
      content_type = "1" # Photos only
      flickr_url = "https://api.flickr.com/services/rest/"
      method = "flickr.photos.search"
      jez = User.find(2)
      black = Colour.find_by_name('black')
      english = Language.find_by_name('English')
      new_photos_count = 0
            
      19.times do |page|
        puts page.to_s
        url = flickr_url + "?api_key=" + key + "&method=" + method + "&page=" + page.to_s + "&per_page=5&content_type=" + content_type + "&extras=date_taken,owner_name,license,geo,description"
        if group_id
          url += "&group_id=" + group_id
        end
        response = open(url)
        doc = REXML::Document.new(response.read)
        doc.elements.each('//rsp/photos/photo') do |photo|
          print "."
          $stdout.flush
          @photo = nil
          file_url = "http://farm" + photo.attributes["farm"] + ".staticflickr.com/" + photo.attributes["server"] + "/" + photo.attributes["id"] + "_" + photo.attributes["secret"] + "_z.jpg"
          photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/" + photo.attributes["id"] + "/"
          @photo = Photo.find_by_url(photo_url)
          inscription_is_stub = true
          if photo.attributes["title"]!=nil
            subject = photo.attributes["title"].split(",")[0].split("()")[0].rstrip.lstrip + "."
            inscription = subject
          end
          if photo.elements["description"].text != nil && photo.elements["description"].text.length > 50
            inscription << " " + photo.elements["description"].text
          end
          if @photo
            puts "photo already exists in Open Plaques"
          else
            # Plaque find by location and name if already exists.....
#            32.76696, -94.348526
#            32.766955, -94.348472
            # Plaque.find_or_create_by_???
            @plaque = Plaque.new(:inscription => inscription, :user => jez, :inscription_is_stub => inscription_is_stub, :colour => black, :language => english)
            @plaque.location = Location.new(:name => 'somewhere in Texas')
            # the Flickr woeids appear to be at town level, so can only create an area from them
            woeid = photo.attributes["woeid"]
            if woeid != nil
              area = Area.find_or_create_by_woeid(woeid)
              if area != nil
                @plaque.location.area = area
              else
                puts "error: provided woeid " + woeid + " but got no area back"
              end
            end
            if @plaque
              @photo = Photo.new
              @photo.plaque = @plaque
              @photo.file_url = file_url
              @photo.url = photo_url
              @photo.taken_at = photo.attributes["datetaken"]
              @photo.photographer_url = photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/"
              @photo.photographer = photo.attributes["ownername"]
              @photo.licence = Licence.find_by_flickr_licence_id(photo.attributes["license"])
              if photo.attributes["latitude"] != "0" && photo.attributes["longitude"] != "0" && !@plaque.geolocated?
                @plaque.latitude = photo.attributes["latitude"]
                @plaque.longitude = photo.attributes["longitude"]
              end
              if @plaque.save
                puts "New plaque and photo added"
              else
                puts "Error adding plaque " + @plaque.errors.full_messages.to_s
              end
              if @photo.save
                puts "New photo found and saved"
              else
                puts "Error saving photo" + @photo.errors.each_full{|msg| puts msg }
              end
            end
          end
        end
      end
    end

  def poi(plaque)
    if plaque.geolocated? && plaque.people.size() > 0
    plaque.longitude.to_s + ', ' + plaque.latitude.to_s + ", \"" + plaque.people.collect(&:name).to_sentence + "\"" + "\r\n"
    end
  end

  def personal_connection_path(pc)
    url_for(:controller => "PersonalConnections", :action => :show, :id => pc.id, :plaque_id => pc.plaque_id)
  end

  def personal_connections_path(plaque)
    url_for(:controller => "PersonalConnections", :action => :index, :plaque_id => plaque.id)
  end

  def edit_personal_connection_path(pc)
    url_for(:controller => "PersonalConnections", :action => :edit, :id => pc.id, :plaque_id => pc.plaque_id)
  end

  def new_personal_connection_path(plaque)
    url_for(:controller => "PersonalConnections", :action => :new, :plaque_id => plaque.id)
  end

  def erected_date(plaque)
    if plaque.erected_at?
      if plaque.erected_at.day == 1 && plaque.erected_at.month == 1
        "in ".html_safe + plaque.erected_at.year.to_s
      else
        "on ".html_safe + plaque.erected_at.strftime('%d %B %Y')
      end
    else
      "sometime in the past"
    end
  end

  def erected_information(plaque)
    info = "".html_safe
    if plaque.erected_at? or !plaque.organisations.empty?
      info += "by ".html_safe if !plaque.organisations.empty?
      org_list = []
      plaque.organisations.each do |organisation|
        org_list << link_to(h(organisation.name), organisation)
      end
      info += org_list.to_sentence.html_safe
      if plaque.erected_at?
        info += " ".html_safe
        if plaque.erected_at.day == 1 && plaque.erected_at.month == 1
          info += "in ".html_safe
        else
          info += "on ".html_safe + plaque.erected_at.strftime('%d %B') + " "
        end
        info += plaque.erected_at.year.to_s
      end
      return content_tag("p", info)
    else
      return content_tag("p", "by ".html_safe + content_tag("span", "unknown".html_safe, :class => :unknown))
    end
  end
  
  def geolocation_if_known(plaque)
    if plaque.geolocated?
      geo_microformat(plaque)
    else
      unknown()
    end
  end

  def map_icon_if_known(plaque)
    if plaque.geolocated?
      geo_map_icon_link(plaque)
    else
      ""
    end
  end

  def google_map_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_map(content, plaque.latitude, plaque.longitude)
    else
      unknown()
    end
  end

  def google_streetview_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_streetview(content, plaque.latitude, plaque.longitude)
    else
      unknown()
    end
  end

  def google_earth_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_earth(content, plaque.id)
    else
      unknown()
    end
  end

  # Generates a link to Open Street Map using latitude ang longitude.
  def link_to_osm(content, latitude, longitude, marker = true)
   link_to(content, "http://www.openstreetmap.org/?lat=" + latitude.to_s + "&amp;lon=" + longitude.to_s + "&amp;zoom=17&amp;mlat=" + latitude.to_s + "&amp;mlon=" + longitude.to_s)
  end

  # Generates a link to Google Maps using latitude ang longitude.
  def link_to_google_map(content, latitude, longitude)
   link_to(content, "http://maps.google.co.uk?q=" + latitude.to_s + "," + longitude.to_s)
  end

  # Generates a link to Google Street View using latitude ang longitude.
  def link_to_google_streetview(content, latitude, longitude)
   link_to(content, "http://maps.google.co.uk/?q=" + latitude.to_s + "," + longitude.to_s + "&layer=c&cbll=" + latitude.to_s + "," + longitude.to_s + "&cbp=12,0,,0,5")
  end

  # Generates a link to Google Earth using id for kml.
  def link_to_google_earth(content, id)
   link_to(content, "http://maps.google.co.uk?t=f&q=http://openplaques.org/plaques/" + id.to_s + ".kml")
  end

  def osm_iframe(latitude, longitude, bboffset = 0.001, height = 200, width = 300, marker = true)
    bb = (longitude - bboffset).to_s + "," + (latitude - bboffset).to_s + "," + (longitude + bboffset).to_s + "," + (latitude + bboffset).to_s

    osm_embed_src = "http://www.openstreetmap.org/export/embed.html?bbox=" + bb + "&amp;marker=" + latitude.to_s + "," + longitude.to_s + "&amp;layer=mapnik"
    return content_tag("iframe","",{:height => height, :width => width, :scrolling => "no", :frameborder => "no", :marginheight => "0", :marginwidth => "0", :src => osm_embed_src, :class => "osm"})
  end

  def geo_microformat(plaque, container = "span")
    if !plaque.geolocated?
      return ""
    end
    @lat = content_tag("span", plaque.latitude, {:class => "latitude", :property => "geo:lat", :about => "#plaque_location"})
    @lon = content_tag("span", plaque.longitude, {:class => "longitude", :property => "geo:long", :about => "#plaque_location"})
    content_tag(container, link_to_osm(@lat + ", " + @lon, plaque.latitude, plaque.longitude), {:class => "geo", :typeof => "geo:Point", :about => "#plaque_location"})
  end

  def geo_map_icon_link(plaque)
    if !plaque.geolocated?
    return "";
    end
    @alt = plaque.latitude.to_s + ", " + plaque.longitude.to_s
    @image = image_tag("map_icon.png", {:alt => @alt})
    link_to_osm(@image, plaque.latitude, plaque.longitude )
  end

  def plaque_icon(plaque)
    if plaque.colour && plaque.colour.slug =~ /(blue|black|yellow|red|white|green)/
      image_tag("icon-" + plaque.colour.slug + ".png", :size => "16x16")
    else
      image_tag("icon-blue.png", :size => "16x16")
    end
  end

  def new_linked_inscription(plaque)
    inscription = plaque.inscription
    connections = plaque.personal_connections.all(:select => "personal_connections.person_id", :group => "personal_connections.person_id")
    if connections.size > 0
      connections.each do |connection|
        if connection.person
          matched = false
          nameparts = connection.person.name.split(" ")

          search_for = connection.person.full_name # Sir Joseph Aloysius Hansom 
          matched = true if inscription.index(search_for) != nil

          if (!matched && connection.person.titled? && nameparts.length > 2)
            search_for = connection.person.title + nameparts.first + " " + nameparts.last # Sir Joseph Hansom 
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && connection.person.titled?)
            search_for = connection.person.title + nameparts.last # Sir Hansom 
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 2)
            search_for = nameparts.first + " " + nameparts.second[0,1] + ". " + nameparts.last # Joseph A. Hansom
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 1)
            search_for = nameparts.first + " " + nameparts.last # Joseph Hansom
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 1)
            search_for = ""
            nameparts.each_with_index do |namepart, index|
              puts index
              search_for += namepart[0,1] + ". " if index != nameparts.length - 1
              search_for += namepart if index == nameparts.length - 1 # J. A. Hansom, J. R. R. Tolkien
            end
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 1)
            search_for = nameparts.first[0,1] + ". " + nameparts.last # J. Hansom
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length == 3)
            search_for = nameparts.second + " " + nameparts.last # Aloysius Hansom
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 1)
            search_for = nameparts.first # Joseph
          end
          matched = true if inscription.index(search_for) != nil

          if (!matched && nameparts.length > 1)
            search_for = nameparts.last # Hansom
          end
          matched = true if inscription.index(search_for) != nil

          inscription = inscription.gsub(search_for, link_to(search_for, person_path(connection.person))).html_safe if matched
        end
      end
    end
    inscription += " [full inscription unknown]" if plaque.inscription_is_stub
    inscription += " [has not been erected yet]" if !plaque.erected? 
    return inscription
  end

  # given a set of plaques, or a thing that has plaques (like an organisation) tell me what the mean point is
  def find_mean(things)
    begin
      @centre = Point.new
      @centre.latitude = 51.475 # Greenwich Meridian
      @centre.longitude = 0
      begin
        @lat = 0
        @lon = 0
        @count = 0
        things.each do |thing|
          if thing.geolocated?
            @lat += thing.latitude
            @lon += thing.longitude
            @count = @count + 1
          end
        end
        @centre.latitude = @lat / @count
        @centre.longitude = @lon / @count
#        puts ("****** lat= " + @centre.latitude.to_s + ",lon= " + @centre.longitude.to_s + " from " + thing.size.to_s + " plaques, " + @count.to_s + " are geolocated")
        return @centre
      rescue
        # oh, maybe it's a thing that has plaques
        return find_mean(thing.plaques)
      end
    rescue
      # something went wrong, failing gracefully
      return @centre
    end
  end

  def geolocation_from(url)
    # https://www.google.com/maps/place/ulitsa+Goncharova,+48,+Ulyanovsk,+Ulyanovskaya+oblast',+Russia,+432011/@54.319775,48.39987,17z/data=!3m1!4b1!4m2!3m1!1s0x415d37692250ea21:0xeab69349916c0171
    p = Point.new
    p.latitude = url[/@+([^,]*)/,1]
    p.longitude = url[/@[\d|.|-]*,+([\d|.|-]*)/,1]
    return p
  end

  class Point
    attr_accessor :precision
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :zoom
  end

end
