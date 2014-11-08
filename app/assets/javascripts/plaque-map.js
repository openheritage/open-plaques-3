var map;
var ajaxRequest;
var plaques=[];
var allow_popups=true;
var plaque_markers = {};


function getXmlHttpObject()
{
  if (window.XMLHttpRequest) { return new XMLHttpRequest(); }
  if (window.ActiveXObject)  { return new ActiveXObject("Microsoft.XMLHTTP"); }
  return null;
}

function addPlaque(geojson)
{
  var features = L.Util.isArray(geojson) ? geojson : geojson.features, i, len, feature;
  if (features)
  {
    for (i = 0, len = features.length; i < len; i++)
    {
      feature = features[i];
      if (feature.geometries || feature.geometry || feature.features || feature.coordinates)
      {
        this.addPlaque(features[i]);
      }
    }
    return this;
  }

  if (geojson.geometry && geojson.properties && geojson.properties.plaque)
  {
    var geometry = geojson.geometry;
    var plaque = geojson.properties.plaque;
    if (plaques["'#"+plaque.id+"'"]==null)
    {
      var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
      var plaque_marker = L.marker([plaque.latitude, plaque.longitude], {icon: plaque_icon});
      if (allow_popups==true)
      {
        var plaque_description = '<div class="inscription">' + truncate(plaque.inscription, 255) + '</div><div class="info">' +
          '<a class="link" href="http://openplaques.org/plaques/' + plaque.id + '">Plaque ' + plaque.id + '</a>';
        plaque_marker.bindPopup(plaque_description);
      }
      clusterer.addLayer(plaque_marker)
      plaques["'#"+plaque.id+"'"]=plaque;
    }
  }
}

function stateChanged()
{
  if (ajaxRequest.readyState==4 && ajaxRequest.status==200)
  {
    var answer = ajaxRequest.responseText;
    var json=JSON.parse(answer);
    addPlaque(json);
  }
}

var msg;
// request the marker info with AJAX for the current bounds
function getPlaques(url)
{
  var bounds=map.getBounds();
  var minll=bounds.getSouthWest(), maxll=bounds.getNorthEast();
  //  bounding box call, e.g. http://openplaques.org/plaques.json?box=[51.5482,-0.1617],[51.5282,-0.1217]
  msg = url + '&box=['+maxll.lat+','+minll.lng+'],['+minll.lat+','+maxll.lng+']';
  ajaxRequest=getXmlHttpObject();
  ajaxRequest.onreadystatechange = stateChanged;
  ajaxRequest.open('GET', msg, true);
  ajaxRequest.send(null);
}

function initmap()
{
  var plaque_map = $("#plaque-map");
  if (plaque_map)
  {
    map = L.map('plaque-map');

    // basemap
    var mapquestUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
    subDomains = ['otile1','otile2','otile3','otile4'],
    mapquestAttrib = 'Map from <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a> &amp; <a href="http://www.openstreetmap.org/" target="_blank">OSM</a>.';
    var mapquest = new L.TileLayer(mapquestUrl, {maxZoom: 18, attribution: mapquestAttrib, subdomains: subDomains});
    map.addLayer(mapquest);

    var latitude = plaque_map.attr("data-latitude"), longitude = plaque_map.attr("data-longitude"), zoom = plaque_map.attr("data-zoom");
    if (zoom)
    {
      var zoom_level = parseInt(zoom);
    } 
    else
    {
      var zoom_level = 14;
    }

    if (latitude && longitude)
    {
      map.setView(L.latLng(parseFloat(latitude),parseFloat(longitude)),zoom_level);
    }
    else
    {
      // start the map in London
      map.setView(L.latLng(51.54281206119232,-0.16788482666015625),zoom_level);
    }

    clusterer = new L.MarkerClusterGroup(
    {
      maxClusterRadius : 25,
      showCoverageOnHover : false,
      iconCreateFunction: function(cluster)
      {
        return new L.DivIcon(
        { 
          html: cluster.getChildCount(), 
          className : 'plaque-cluster-marker ' + clusterSize(cluster.getChildCount()), 
          iconSize: clusterWidth(cluster.getChildCount())
        });
      }
    });
    map.addLayer(clusterer);

    var data_view = plaque_map.attr("data-view");
    if (data_view == "one")
    {
  		var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
      L.marker([parseFloat(latitude),parseFloat(longitude)], { icon: plaque_icon }).addTo(map);
    }
    else
    {
  		var data_path = plaque_map.attr("data-path");
      var geojsonURL = "/plaques/tiles/{z}/{x}/{y}.json";
      if (data_view == "unphotographed") {
        geojsonURL = "/plaques/unphotographed/tiles/{z}/{x}/{y}.json";
        data_view = "all"
      };
  		if (data_view == "all")
      {
 //       console.log(geojsonURL);
        var geojsonTileLayer = new L.TileLayer.GeoJSON(geojsonURL, 
          {
            clipTiles: false
          },
          {
            onEachFeature: function(feature, layer)
            {
              if (feature.properties && feature.properties.plaque)
              {
                var plaque = feature.properties.plaque;
                var plaque_description = '<div class="inscription">' + truncate(plaque.inscription, 255) + '</div><div class="info">' +
                '<a class="link" href="http://openplaques.org/plaques/' + plaque.id + '">Plaque ' + plaque.id + '</a>';
                layer.bindPopup(plaque_description);
                var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
                layer.setIcon(plaque_icon);
                if (plaques["'#"+plaque.id+"'"]==null)
                {
                  plaques["'#"+plaque.id+"'"]=plaque;
                  clusterer.addLayer(layer);
                }
              }
            }
          }
        );
        map.addLayer(geojsonTileLayer);
  		}
      else if (data_path)
      {
  		   var url = data_path;
         getPlaques(url); 
         map.on('moveend', function() { getPlaques(url) });
  		}
      else
      {
  		   var url = document.location.href.replace(/\?.*/,'') + '.json?data=simple&limit=1000';
         getPlaques(url);
         map.on('moveend', function() { getPlaques(url) });
  		}
	  }
  }
}

function clusterSize(number) {
	if (number < 10) {
		return 'small';
	} else if (number < 100) {
		return 'medium';
	} else  {
		return 'large';
	}
}

function clusterWidth(number) {
	if (number < 10) {
		return 20;
	} else if (number < 100) {
		return 30;
	} else  {
		return 40;
	}
}

function truncate(string, max_length) {
	if (string.length > max_length) {
		return string.substring(0, max_length) + '...';
	} else {
		return string;
	}
}

$(document).ready(function() {
  if ($("#plaque-map").length) {
    initmap();
  }
})