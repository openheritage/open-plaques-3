// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require tether
//= require popper
//= require bootstrap
//= require jquery-ui
//= require jquery_ujs
//= require leaflet
//= require markercluster
//= require tile.stamen
//= require RGraph.hbar.js
//= require RGraph.common.zoom.js
//= require RGraph.common.tooltips.js
//= require RGraph.common.resizing.js
//= require RGraph.common.key.js
//= require RGraph.common.effects.js
//= require RGraph.common.dynamic.js
//= require RGraph.common.core.js
//= require RGraph.common.context.js
//= require RGraph.common.annotate.js
//= require_tree .

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload !== 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}
