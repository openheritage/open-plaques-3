xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.osm(:version=>"0.6",:generator=>"openplaques.org") do
  @plaques.each_with_index { | plaque, index |
    if plaque.geolocated?
      xml.node(:id=>-1*index-1, :visible=>'true', :lat=>plaque.latitude, :lon=>plaque.longitude) do
        xml.tag(:k=>'created_by', :v=>'openplaques.org')
        xml.tag(:k=>'ref', :v=>plaque.machine_tag)
        xml.tag(:k=>'landmark', :v=>'memorial_plaque')
        xml.tag(:k=>'name', :v=>plaque.title)
        xml.tag(:k=>'note', :v=>plaque.inscription)
      end
    end
  }
end
