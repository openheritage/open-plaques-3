function latLongChanged() {
    var latLong = $('#plaque_latitude').val().split(',');
    if (latLong.length === 2) {
        $('#plaque_latitude').val(latLong[0].trim());
        $('#plaque_longitude').val(latLong[1].trim());
    }
}

$('#plaque_latitude').change(latLongChanged);
$('#plaque_latitude').keyup(latLongChanged);

String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g, "");
}
