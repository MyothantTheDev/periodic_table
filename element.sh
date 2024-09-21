#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
COLUMNS="atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type"

MAIN() {
  if [ -z $1 ]
  then
    echo "Please provide an element as an argument."
  else
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      ARGS="atomic_number"
    elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
    then
      ARGS="symbol"
    elif [[ $1 =~ ^[A-Za-z]+$ ]]
    then
      ARGS="name"
    else
      MAIN
    fi
    DETAIL_ELEMENT $ARGS $1
  fi
}

DETAIL_ELEMENT() {
  case $1 in
    "atomic_number")
        ELEMENT_RESULT=$($PSQL "SELECT $COLUMNS FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number = $2;")
        ;;
    "symbol")
        ELEMENT_RESULT=$($PSQL "SELECT $COLUMNS FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol = '$2';")
        ;;
    "name")
        ELEMENT_RESULT=$($PSQL "SELECT $COLUMNS FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name = '$2';")
        ;;
    *)
        echo "Invalid option!"
        ;;
  esac

  if [[ -z $ELEMENT_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    echo $ELEMENT_RESULT | while IFS="|" read -r atomic_number symbol name atomic_mass melting_point boiling_point type
    do
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    done
  fi
}

MAIN $1