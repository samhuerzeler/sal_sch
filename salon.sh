#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~ MY SALON ~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_SERVICES() {

  if [[ $1 ]]
  then
    echo -e "\n$1";
  fi
  
  # get and display services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while IFS="|" read ID NAME
  do
    SERVICE_ID=$(echo $ID | sed 's/ //g')
    SERVICE_NAME=$(echo $NAME | sed 's/ //g')
    echo "$ID) $SERVICE_NAME"
  done

  # get user input
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5])
          ADD_APPOINTMENT
          ;;
        *)
          GET_SERVICES "I could not find that service. What would you like today?"
          ;;
  esac

}

ADD_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$NAME', '$CUSTOMER_PHONE')")
  fi

  SERVICE_NAME_Q=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME_Q | sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

GET_SERVICES
