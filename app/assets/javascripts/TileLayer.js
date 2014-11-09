// Load data tiles from an AJAX data source
L.TileLayer.Ajax = L.TileLayer.extend({
    _requests: [],
    _cache: [],
    _addTile: function (tilePoint) {
        var tile = { datum: null, processed: false };
        zoom = this._map._zoom;
        this._loadTile(zoom, tile, tilePoint);
    },
    // XMLHttpRequest handler; closure over the XHR object, the layer, and the tile
    _xhrHandler: function (req, layer, tile) {
        return function () {
            if (req.readyState !== 4) {
                return;
            }
            var s = req.status;
            if ((s >= 200 && s < 300) || s === 304) {
                tile.datum = JSON.parse(req.responseText);
                layer._tileLoaded(tile);
            } else {
                layer._tileLoaded(tile);
            }
        };
    },
    // Load the requested tile via AJAX
    _loadTile: function (zoom, tile, tilePoint) {
        if (zoom < 14) {
            // zoomed out to a level where the map tile covers a large geographic area
            // this could lead to a long-running sql query
            // splitting the map tile call into the equivalent of zooming in one level
            // 4 quadrants -> top-left, top-right, bottom-right, bottom-left
            // this will recurse until zoomed in sufficiently
            var tempX = tilePoint.x * 2;
            var tempY = tilePoint.y * 2;
            var newZoom = zoom + 1;

            tilePoint1 = tilePoint.clone();
            tilePoint1.x = tempX;
            tilePoint1.y = tempY;
            tile1 = { datum: null, processed: false };
            this._loadTile(newZoom, tile1, tilePoint1);

            tilePoint2 = tilePoint.clone();
            tilePoint2.x = tempX + 1;
            tilePoint2.y = tempY;
            tile2 = { datum: null, processed: false };
            this._loadTile(newZoom, tile2, tilePoint2);

            tilePoint3 = tilePoint.clone();
            tilePoint3.x = tempX;
            tilePoint3.y = tempY + 1;
            tile3 = { datum: null, processed: false };
            this._loadTile(newZoom, tile3, tilePoint3);

            tilePoint4 = tilePoint.clone();
            tilePoint4.x = tempX + 1;
            tilePoint4.y = tempY + 1;
            tile4 = { datum: null, processed: false };
            this._loadTile(newZoom, tile4, tilePoint4);
        } 
        else if (zoom > 14)
        {
            // zoomed in to too fine a detail
            // we will hit the cache more often if all calls are at the same zoom number
            var tempX = Math.round(tilePoint.x / 2);
            var tempY = Math.round(tilePoint.y / 2);
            var newZoom = zoom - 1;
            tilePoint5 = tilePoint.clone();
            tilePoint5.x = tempX;
            tilePoint5.y = tempY;
            tile5 = { datum: null, processed: false };
            this._loadTile(newZoom, tile5, tilePoint5);
        }
        else
        {
            json_url = this.getTileUrl(tilePoint);
            json_url = json_url.replace(/tiles\/([\d]*)/, 'tiles/14')
            if (null == this._cache[json_url])
            {
                this._cache[json_url] = true;
                var layer = this;
                var req = new XMLHttpRequest();
                this._requests.push(req);
                req.onreadystatechange = this._xhrHandler(req, layer, tile);
                req.open('GET', json_url, true);
                req.send();
            }
        }
    },
    _reset: function () {
        L.TileLayer.prototype._reset.apply(this, arguments);
        for (var i in this._requests) {
            this._requests[i].abort();
        }
        this._requests = [];
    },
    _update: function () {
        if (this._map._panTransition && this._map._panTransition._inProgress) { return; }
        if (this._tilesToLoad < 0) { this._tilesToLoad = 0; }
        L.TileLayer.prototype._update.apply(this, arguments);
    }
});


L.TileLayer.GeoJSON = L.TileLayer.Ajax.extend({

    initialize: function (url, options, geojsonOptions) {
        L.TileLayer.Ajax.prototype.initialize.call(this, url, options);
        this.geojsonLayer = new L.GeoJSON(null, geojsonOptions);
    },

    onAdd: function (map) {
        this._map = map;
        L.TileLayer.Ajax.prototype.onAdd.call(this, map);
        map.addLayer(this.geojsonLayer);
    },

    onRemove: function (map) {
        map.removeLayer(this.geojsonLayer);
        L.TileLayer.Ajax.prototype.onRemove.call(this, map);
    },

    _reset: function () {
        this.geojsonLayer.clearLayers();
        L.TileLayer.Ajax.prototype._reset.apply(this, arguments);
    },

    _recurseLayerUntilPath: function (func, layer) {
        if (layer instanceof L.Path) {
            func(layer);
        }
        else if (layer instanceof L.LayerGroup) {
            layer.getLayers().forEach(this._recurseLayerUntilPath.bind(this, func), this);
        }
    },

    // Add a geojson object from a tile to the GeoJSON layer
    addTileData: function (geojson) {
        var features = L.Util.isArray(geojson) ? geojson : geojson.features, i, len, feature;
        if (features) {
            for (i = 0, len = features.length; i < len; i++) {
                feature = features[i];
                if (feature.geometries || feature.geometry || feature.features || feature.coordinates) {
                    this.addTileData(features[i]);
                }
            }
            return this;
        }
        var options = this.geojsonLayer.options;
        var parentLayer = this.geojsonLayer;
        var incomingLayer = null;
        try {
            incomingLayer = L.GeoJSON.geometryToLayer(geojson, options.pointToLayer, options.coordsToLatLng);
        }
        catch (e) {
            return this;
        }
        incomingLayer.feature = L.marker(geojson.geometry.coordinates);
        incomingLayer.defaultOptions = incomingLayer.options;
        this.geojsonLayer.resetStyle(incomingLayer);
        if (options.onEachFeature) {
            options.onEachFeature(geojson, incomingLayer);
        }
        parentLayer.addLayer(incomingLayer);
        return this;
    },

    _tileLoaded: function (tile) {
        L.TileLayer.Ajax.prototype._tileLoaded.apply(this, arguments);
        if (tile.datum === null) { return null; }
        this.addTileData(tile.datum);
    }
});
