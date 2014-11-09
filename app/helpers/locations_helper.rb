module LocationsHelper

  def location_if_known(plaque)
    if plaque.location
      address(plaque.location)
    else
      unknown()
    end
  end

  def address(location)
    if location.area
      return (location.name + ", " + location.area.name + "," + location.country.to_s)
    else
      link_to location.name, location
    end
  end

end
