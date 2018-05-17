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
      text = " " + text + " "
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

  def find_flickr_photos_non_api(plaque)
    url = "https://www.flickr.com/search/?tags=#{plaque.machine_tag}%20"
    response = ""
    open(url){|f| response = f.read }
    pics = response.match( /\[{"_flickrModelRegistry":"photo-lite-models".*?\]/ )
    pics = "[]" if pics == nil
    json_parsed = JSON.parse("{\"data\":#{pics}}")
    json_parsed['data'].each do |pic|
      photo_url = "https://www.flickr.com/photos/#{pic['ownerNsid']}/#{pic['id']}/"
      @photo = Photo.find_by_url(photo_url) || Photo.find_by_url(photo_url.sub("https:","http:"))
      if @photo
#        puts "we've already got #{photo_url}"
      else
        @photo = Photo.new(url: photo_url, plaque: plaque)
        @photo.populate
        @photo.save
      end
    end
  end

  # pass null plaque and flickr_user_id to search all machinetagged photos on Flickr
  def find_photo_by_machinetag(plaque, flickr_user_id)
#    key = FLICKR_KEY
    key = "86c115028094a06ed5cd19cfe72e8f8b"
    repeat = plaque ? 1 : 20 # 100 per page, we will check the 2000 most recently created Flickr images
    repeat.times do |page|
      machine_tag = plaque ? plaque.machine_tag : "openplaques:id="
      url = "https://api.flickr.com/services/rest/?api_key=#{key}&method=flickr.photos.search&page=#{page.to_s}&content_type=1&machine_tags=#{machine_tag}&extras=date_taken,owner_name,license,geo,machine_tags"
      if (flickr_user_id)
        url += "&user_id=#{flickr_user_id}"
      end
      puts "Flickr: #{url}"
      response = open(url)
      doc = REXML::Document.new(response.read)
      doc.elements.each('//rsp/photos/photo') do |photo|
        $stdout.flush
        @photo = nil
        photo_url = "https://www.flickr.com/photos/#{photo.attributes['owner']}/#{photo.attributes['id']}/"
        @photo = Photo.find_by_url(photo_url) || Photo.find_by_url(photo_url.sub("https:","http:"))
        if @photo
          # we've already got that one
        else
          plaque_id = photo.attributes['machine_tags'][/openplaques\:id\=(\d+)/, 1]
          @plaque = Plaque.find_by_id(plaque_id)
          if @plaque
            @photo = Photo.new(url: photo_url, plaque: @plaque)
            @photo.populate
            @photo.save
          else
            puts "Photo's machine tag doesn't match a plaque."
          end
        end
      end
    end
  end

  def crawl_kentucky()
    agent = Mechanize.new
    page = agent.get('http://migration.kentucky.gov/kyhs/hmdb/MarkerSearch.aspx')
    form = page.form('aspnetForm')
    field = form.field_with(name: 'ctl00$MainContentPlaceHolder$searchCriteriaControl$numberTextBox')
    submit_button = form.button_with(name: 'ctl00$MainContentPlaceHolder$searchCriteriaControl$searchByNumberButton')

    kentucky_historical_society = Organisation.find_by_slug("kentucky_historical_society")
    kentucky_highways_department = Organisation.find_by_slug("kentucky_highways_department")
    kentucky_historical_marker = Series.find_by_name("Kentucky Historical Marker")
    usa = Country.find_by_name("United States")
    black = Colour.find_by_name("black")
    english = Language.find_by_name("English")
    (1..2533).each do |series_ref|
      field.value = series_ref
      output = agent.submit(form, submit_button)
      marker_number = output.search('.//tr[contains(th,"Marker Number")]/td/text()').text.strip
      if marker_number == ""
        puts "#{series_ref} does not exist"
      else
        title = output.search('.//caption').text.strip
        inscription = output.search('.//tr[contains(th,"Description")]/td').text.strip
        location = output.search('.//tr[contains(th,"Location")]/td/text()').text.strip
        puts "#{marker_number} #{location} #{inscription}"
        plaque = Plaque.where(series_id: kentucky_historical_marker.id, series_ref: series_ref).first
        plaque = Plaque.new() if !plaque
        plaque.address = location
        plaque.inscription = "#{title}. #{inscription}"
        plaque.colour = black
        plaque.language = english
        plaque.series = kentucky_historical_marker
        plaque.series_ref = marker_number
        known_names = [
          "Athens","Augusta",
          "Bardstown",
          "Brandenburg","Brownsville",
          "Cloverport",
          "Danville",
          "Elizabethtown","Elkhorn City",
          "Frankfort",
          "Georgetown","Glasgow","Grants Lick","Greensburg","Greenville",
          "Hopkinsville",
          "Lebanon","Lexington","Louisville",
          "Maysville","Monticello",
          "Paducah",
          "Radcliff","Russellville",
          "Sulphur Well",
          "Williamsburg"
        ]
        known_names.each do |known_name|
          if (location.include?(known_name))
            area = Area.find_or_create_by(name: "#{known_name}, KY")
            if (!area.country)
              area.country = usa
              area.save
            end
            plaque.area = area
            if plaque.address.end_with?(", #{known_name}")
              plaque.address = plaque.address.reverse.sub(", #{known_name}".reverse, "").reverse
            end
            break
          end
        end
        plaque.save
        s = Sponsorship.find_or_create_by(plaque_id: plaque.id, organisation_id: kentucky_historical_society.id)
        s.save
        s = Sponsorship.find_or_create_by(plaque_id: plaque.id, organisation_id: kentucky_highways_department.id)
        s.save
      end
    end
  end

  def north_carolina(state, series, series_ref, colour, sponsors = [])
    begin
      output = Nokogiri::HTML(open("http://www.ncmarkers.com/Markers.aspx?MarkerId=#{series_ref}"))
    rescue OpenURI::HTTPError
      puts "ref #{series_ref} not found"
      return
    end
    marker_number = output.search('.//input[@name="txtID"]/@value').text.strip
    if marker_number == ""
      puts "#{series_ref} does not exist"
    else
      title = output.search('.//input[@name="txtTitle"]/@value').text.titlecase.strip
      inscription = output.search('.//textarea[@name="txtMarkerText"]').text.strip
      location = output.search('.//textarea[@name="txtLocation"]').text.strip
      location += ", #{state}"
      created = output.search('.//input[@name="txtYear"]/@value').text.strip
      puts "#{series.name} number #{marker_number} at #{location} == #{title}"

      plaque = Plaque.find_or_create_by(series_id: series.id, series_ref: series_ref)
      plaque.address = location
      plaque.force_us_state = state
      plaque.inscription = "#{title}. #{inscription}"
      plaque.colour = colour
      plaque.language = Language.find_by_name('English')
      plaque.series = series
      plaque.series_ref = marker_number
      plaque.save
      sponsors.each do |sponsor|
        s = Sponsorship.find_or_create_by(plaque_id: plaque.id, organisation_id: sponsor.id)
        s.save
      end
    end
  end

  def crawl_nevada
    j = JSON.parse(open("http://shpo.nv.gov/historical-markers-json").read)
    j.each do |js|
      nevada(js['marker_number'], js['slug'], js['latitude'], js['longitude'], js['city'], js['county'])
    end
  end

  # http://shpo.nv.gov/historical-markers-json
  def nevada(marker_number, slug, latitude, longitude, city, county)
    begin
      output = Nokogiri::HTML(open("http://shpo.nv.gov/nevadas-historical-markers/historical-markers/#{slug}"))
    rescue OpenURI::HTTPError
      puts "slug #{slug} not found"
      return
    end
    not_found = output.search('.//h1').text.strip
    if not_found == "404"
      puts "#{slug} does not exist"
    else
      sponsors = []
      series = Series.find 59
      state = "NV"
      title = output.search('.//article/h1').text.titlecase.strip
      inscription = output.search('.//article/p').text.strip
      inscription += output.search('.//article/h3').text.strip
      usa = Country.find_by_alpha2('us')
      area = Area.find_or_create_by(country: usa, name: "#{city}, #{state}")
      puts "#{series.name} number #{marker_number} at #{area.name} == #{title}"
      plaque = Plaque.find_by(series_id: series.id, series_ref: marker_number)
      if (plaque)
        puts "#{series.name} number #{marker_number} already exists"
      else
        plaque = Plaque.new(series_id: series.id, series_ref: marker_number, area: area, latitude: latitude, longitude: longitude) if !plaque
        if /MARKER/.match(inscription)
          matches = /([\w\W]*)([\bNEVADA\b\s]*[\bSTATE OF NEVADA\b\s]*[STATE\b\s]*[\bCENTENNIAL\b\s]*[\bHISTORIC[AL]*\b\s]*MA[R]*KER)\s(NO[.]*|number|NUMBER)\W*(\d*)\W*(.*)\W*(.*)\W*(.*)\W*(.*)\W*(.*)\W*/i.match(inscription)
          plaque.inscription = "#{title}."
          if (matches && matches[1])
            plaque.inscription += " #{matches[1].gsub('NEVADA CENTENNIAL','').gsub('CENTENNIAL','').gsub('STATE HISTORICAL','')}"
          else
            plaque.inscription += inscription
          end
          if (matches && matches[5])
            extra_sponsors = matches[5].gsub(/STATE HISTORIC PRESERVATION OFFICE/i,'').strip
            sponsors << Organisation.find_or_create_by(name: extra_sponsors.titleize) unless extra_sponsors.blank?
          end
          sponsors << Organisation.find_or_create_by(name: 'Nevada State Historic Preservation Office')
          plaque.language = Language.find_by_name('English')
          plaque.save
          sponsors.each do |sponsor|
            s = Sponsorship.find_or_create_by(plaque_id: plaque.id, organisation_id: sponsor.id)
            s.save
          end
        end
      end
    end
  end

  # when you are pretty sure a group contains plaques
  def crawl_flickr(group_id='74191472@N00')
    return if !group_id
    key = "86c115028094a06ed5cd19cfe72e8f8b"
    (1..1000).each do |page|
      q_url = "https://api.flickr.com/services/rest/?api_key=#{key}&method=flickr.photos.search&page=#{page.to_s}&per_page=10&content_type=1&group_id=#{group_id}"
      puts q_url
      begin
        response = open(q_url)
      rescue # random 502 bad gateway from Flickr
        sleep(5)
        response = open(q_url)
      end
      doc = REXML::Document.new(response.read)
      pages = doc.root.elements['photos'].attributes['pages']
      puts "#{page} of #{pages}"
      doc.elements.each('//rsp/photos/photo') do |photo|
        $stdout.flush
        photo_url = "https://www.flickr.com/photos/#{photo.attributes['owner']}/#{photo.attributes['id']}/"
        @photo = Photo.new(url: photo_url)
        @photo.populate
        @photo.match
        @photo.save
      end
      break if page.to_i >= pages.to_i
    end
  end

  def poi(plaque)
    if plaque.geolocated? && plaque.people.size() > 0
    plaque.longitude.to_s + ', ' + plaque.latitude.to_s + ", \"" + plaque.people.collect(&:name).to_sentence + "\"" + "\r\n"
    end
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
    if plaque.erected_at? || plaque.organisations.size > 0
      info += "by ".html_safe if plaque.organisations.size > 0
      org_list = []
      plaque.organisations.each do |organisation|
        org_list << link_to(h(organisation.name), organisation)
      end
      info += org_list.to_sentence.html_safe
      if plaque.erected_at?
        info += " ".html_safe
        info += erected_date(plaque)
      end
      return info
    end
  end

  def linked_inscription(plaque)
    inscription = plaque.inscription.split.join(' ').strip.gsub('  ',' ')
    people = plaque.people
    if people
      reduced_inscription = inscription
      people.each_with_index do |person, person_index|
        matched = false
        search_for = ""
        i = 0
        person.names.each_with_index do |name, index|
          if (!matched)
            search_for = name
            matched = reduced_inscription.upcase.index(search_for.upcase) != nil
            i = reduced_inscription.upcase.index(search_for.upcase)
          end
        end
        reduced_inscription = "#{reduced_inscription[0..i]}#{reduced_inscription[(i + search_for.length - 1)..-1]}" if matched
        i_inscription = inscription.upcase.index(search_for.upcase)
        inscription = "#{inscription[0..(i_inscription - 1)] if i_inscription > 0}#{link_to(search_for, person_path(person))}#{inscription[(i_inscription + search_for.length)..-1]}" if i
      end
    end
    inscription += " [full inscription unknown]" if plaque.inscription_is_stub
    inscription += " [has not been erected yet]" if !plaque.erected?
    return inscription.html_safe
  end

  def simple_inscription(plaque)
    inscription = plaque.inscription.split.join(' ').strip.gsub('  ',' ')
    inscription += " [full inscription unknown]" if plaque.inscription_is_stub
    inscription += " [has not been erected yet]" if !plaque.erected?
    return inscription.html_safe
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
    # https://www.google.com/maps/@37.0625,-95.677068,4z
    p = Point.new
    r = /@([-\d.\d]*),([-\d.\d]*)/
    if (url[r])
      p.latitude = url[r,1].to_f.round(5)
      p.longitude = url[r,2].to_f.round(5)
      return p
    end
    # or OSM
    # https://www.openstreetmap.org/#map=17/57.14772/-2.10572
    r = /map=[\d]*\/([-\d.\d]*)\/([-\d.\d]*)/
    if (url[r])
      p.latitude = url[r,1].to_f.round(5)
      p.longitude = url[r,2].to_f.round(5)
      return p
    end
    # or Geohack
    # https://tools.wmflabs.org/wiwosm/osm-on-ol/commons-on-osm.php?zoom=16&lat=43.725688888889&lon=7.2722138888889
    r = /&lat=([-\d.\d]*)&lon=([-\d.\d]*)/
    if (url[r])
      p.latitude = url[r,1].to_f.round(5)
      p.longitude = url[r,2].to_f.round(5)
      return p
    end
    p
  end

  class Point
    attr_accessor :precision
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :zoom

    def as_wkt
      'POINT(' + self.latitude.to_s + ' ' + self.longitude.to_s + ')'
    end
  end

end
