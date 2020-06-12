for country in */ ; do
  echo "country:" $country
  for city_or_state in ${country}*/ ; do
    if [ -d ${city_or_state} ]; then
      echo "city or state:" ${city_or_state}
      for city in ${city_or_state}*/ ; do
        if [ -d ${city} ]; then
          echo "merge plaques for " $city
          rm ${city}plaques.json
          echo "[" >> ${city}plaques.json
          awk 'y {print s} {s=$0;y=1} END {ORS="\r\n]"; print s}' ORS="," ${city}[1-9]*.json >> ${city}plaques.json
        fi
      done
      echo "merge plaques for " ${city_or_state}
      rm ${city_or_state}plaques.json
      echo "[" >> ${city_or_state}plaques.json
      awk 'y {print s} {s=$0;y=1} END {ORS="\r\n]"; print s}' ORS="," ${city_or_state}[1-9]*.json >> ${city_or_state}plaques.json
      if [[ -f ${city_or_state}/plaques.json && -s ${city_or_state}/plaques.json ]]; then
        echo "do nothing"
      else
        echo "merge plaques for state " ${city_or_state}
        rm ${city_or_state}/plaques.json
        echo "[" >> ${city_or_state}plaques.json
        awk '!/^[\]\[]/{print} END {ORS="\r\n]"; print s}' ORS="," ${city_or_state}*/plaques.json >> ${city_or_state}/plaques.json
      fi
    fi
  done
  echo "merge plaques for country"
  rm ${country}/plaques.json
  echo "[" >> ${country}plaques.json
  awk '!/^[\]\[]/{print} END {ORS="\r\n]"; print s}' ORS="," ${country}*/plaques.json >> ${country}/plaques.json
done