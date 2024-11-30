#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ $1 ]]; then
  # Check if input is numeric (atomic number)
  if [[ $1 =~ ^[0-9]+$ ]]; then
    ELEMENT=$($PSQL "SELECT atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type 
                     FROM properties 
                     JOIN elements USING (atomic_number) 
                     JOIN types USING (type_id) 
                     WHERE atomic_number = $1 LIMIT 1;")
  else
    # Non-numeric input: Match exactly with symbol or name
    ELEMENT=$($PSQL "SELECT atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, name, type 
                     FROM properties 
                     JOIN elements USING (atomic_number) 
                     JOIN types USING (type_id) 
                     WHERE symbol = '$1' OR name = '$1' LIMIT 1;")
  fi

  # If no element is found
  if [[ -z $ELEMENT ]]; then
    echo "I could not find that element in the database."
  else
    # Read and format the output
    echo "$ELEMENT" | while IFS=\| read ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT BOILING_POINT SYMBOL NAME TYPE; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
else
  echo "Please provide an element as an argument."
fi
