function latLongChanged() {
    var latLong = $('#plaque_latitude').val().split(',');
    if (latLong.length === 2) {
        $('#plaque_latitude').val(latLong[0].trim());
        $('#plaque_longitude').val(latLong[1].trim());
        $('#latlonlink').val(latLong[0].trim() + ',' + latLong[1].trim() + ' on Google Maps');
        $('#latlonlink').prop("href", 'https://maps.google.com/maps?q=' + latLong[0].trim() + ',' + latLong[1].trim() + '&z=18');
    }
}

$('#plaque_latitude').change(latLongChanged);
$('#plaque_latitude').keyup(latLongChanged);

String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g, "");
}
