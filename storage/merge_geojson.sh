#for country in */ ; do
for country in 'united-kingdom' ; do
  echo "country:" $country
  for city_or_state in ${country}/* ; do
    if [ -d ${city_or_state} ]; then
      echo "city or state:" ${city_or_state}
#      for city in ${city_or_state}/*/ ; do
#        if [ -d ${city} ]; then
#          echo "merge state-city plaques for " $city
#          rm ${city}plaques.geojson
#          echo "{
#\"type\": \"FeatureCollection\",
#\"name\": \""${city_or_state}" plaques\",
#\"features\": [" >> ${city}plaques.geojson
#          awk 'y {print s} {s=$0;y=1} END {ORS="\r\n]"; print s}' ORS="," ${city}[1-9]*.geojson >> ${city}plaques.geojson
#        fi
#      done
      echo "merge plaques for city" ${city_or_state}
      rm ${city_or_state}/plaques.geojson
      echo "{
  \"type\": \"FeatureCollection\",
  \"name\": \""${city_or_state}" plaques\",
  \"features\": [" >> ${city_or_state}/plaques.geojson
      awk 'y {print "   ",s} {s=$0;y=1} END {ORS="\r\n  ]\r\n}"; print "   ",s}' ORS=",\r\n" ${city_or_state}/[1-9]*.geojson >> ${city_or_state}/plaques.geojson
      if [[ -f ${city_or_state}/plaques.geojson && -s ${city_or_state}/plaques.geojson ]]; then
        echo ""
      else
        echo "merge plaques for state " ${city_or_state}
#        rm ${city_or_state}/plaques.geojson
#        echo "[" >> ${city_or_state}/plaques.geojson
#        awk '!/^[\]\[]/{print} END {ORS="\r\n]"; print s}' ORS="," ${city_or_state}*/plaques.geojson >> ${city_or_state}/plaques.geojson
      fi
    fi
  done
  echo "merge plaques for country"
  rm ${country}/plaques.geojson
  echo "{
  \"type\": \"FeatureCollection\",
  \"name\": \""${country}" plaques\",
  \"features\": [" >> ${country}/plaques.geojson
  awk '/{\"type\":\"Feature\".*,\r/{ print $0 } /{\"type\":\"Feature\".*}\r/{ print $0"," } END {ORS="  ]\r\n}"; print s}' ${country}/*/plaques.geojson >> ${country}/plaques.geojson
  # awk -v line=2 '{a[NR]=$0} END{for (i=1;i<=NR;i++) if (i != (NR-line)) print a[i]}' ${country}/plaques.geojson > ${country}/plaques2.geojson
done