Hikr Elevation Service
======================

Parses GeoJSON files (sent as pasted text) by adding elevation to all coordinates: paths, points and polygons. _Requires SRTM data_.


**Warning** 
If you7re trying to run this service and coming up with errors, note the `elevation` folder. For the elevation service to function properly, it needs to be filled with .hgt files in the SRTM format, named according to the pattern `N34E135.hgt`. The script assumes this file to contain elevation data for latitude 34 degrees north and longitude 135 degrees east. 

Thanks
------

Big thanks to Henri for hosting the service and Frank for setting up the cloud instance and making sure it runs.

This service wouldn't be possible without NASA's SRTM data.

License
-------
The code is licensed under the MIT license. See License.md for details. 

