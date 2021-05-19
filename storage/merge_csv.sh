for country in 'gb/'; do # */ ; do
  echo "country:" $country
  for city_or_state in ${country}*/ ; do
    if [ -d ${city_or_state} ]; then
      echo "city or state:" ${city_or_state}
      for city in ${city_or_state}*/ ; do
        if [ -d ${city} ]; then
          echo "merge plaques for " $city
          awk '(NR == 1) || (FNR > 1)' ${city}[1-9]*.csv > ${city}plaques.csv
        fi
      done
      echo "merge plaques for " ${city_or_state}
      awk '(NR == 1) || (FNR > 1)' ${city_or_state}[1-9]*.csv > ${city_or_state}plaques.csv
      if [[ -f ${city_or_state}/plaques.csv && -s ${city_or_state}/plaques.csv ]]; then
        echo "do nothing"
      else
        echo "merge plaques for state"
        awk '(NR == 1) || (FNR > 1)' ${city_or_state}*/plaques.csv > ${city_or_state}/plaques.csv
      fi
    fi
  done
  echo "merge plaques for country"
  awk '(NR == 1) || (FNR > 1)' ${country}*/plaques.csv > ${country}/open-plaques-${country}-2012-05-14.csv
done