module MapsHelper

  def google_maps_path(latitude, longitude, options = {})

    width = options[:width] || 300
    height = options[:height] || 300
    colour = options[:colour] || "blue"
    zoom = options[:zoom] || 16
    maptype = options[:maptype] || nil

    params = []

    options[:styles].each_pair do |feature, value|
      style = "style=feature:" + feature.to_s

      value.each_pair do |element, value|

        style += "|element:" + element.to_s

        rules = []

        value.each_pair do |rule, value|
          rules << rule.to_s + ":" + value.to_s
        end

        style += "|" + rules.join("|")
      end

      params << style

    end

    url = "http://maps.google.com/maps/api/staticmap?"
    params << "size=" + width.to_s + "x" + height.to_s
    params << "markers=color:" + colour + "|" + latitude.to_s + "," + longitude.to_s
    params << "sensor=false"
    params << "zoom=" + zoom.to_s
    params << "maptype=" + maptype if maptype


    url + params.join("&")

  end

end