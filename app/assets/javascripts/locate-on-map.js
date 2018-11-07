var map = null
var lat_element = null
var lon_element = null
var geolocation = new L.LatLng(52, 0)
var view = 5

document.addEventListener("DOMContentLoaded", function()
{
  lat_element = document.querySelectorAll('[name$="[latitude]"]')[0]
  lon_element = document.querySelectorAll('[name$="[longitude]"]')[0]

  if (lat_element && lon_element) {
    lat_element.addEventListener('blur', update_map)
    lon_element.addEventListener('blur', update_map)

    update_geolocation_from_text_fields();

    var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 })

    map = L.map('map').setView(geolocation, view)
    map.scrollWheelZoom.disable()
    var basemap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    	maxZoom: 19,
    	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    })
    map.addLayer(basemap)
    marker = L.marker(geolocation, {draggable: true, icon: plaque_icon})
    marker.on('dragend', update_text_fields_from_marker)
    marker.addTo(map)
  }

  function update_geolocation_from_text_fields()
  {
    if (lat_element && lat_element.value != '' && lon_element && lon_element.value != '')
    {
      geolocation.lat = lat_element.value
      geolocation.lng = lon_element.value
      view = 18
    }
  }

  function update_map()
  {
    update_geolocation_from_text_fields()
    marker.setLatLng(geolocation)
    map.setView(geolocation, view)
  }

  function update_text_fields_from_marker()
  {
    lat_element.value = marker.getLatLng().lat
    lon_element.value = marker.getLatLng().lng
  }
})
