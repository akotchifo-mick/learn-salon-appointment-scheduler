#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to my salon, how can I help you?" 
  SERVICES=$($PSQL "select * from services")  
  # display available services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  READ_INPUT   
}

READ_INPUT() {
  #get user service choice
  read SERVICE_ID_SELECTED
  #if input not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_MENU "Enter a valid number :"
  else
    SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

    while [[ -z $SERVICE_NAME ]] 
    do
      SERVICES=$($PSQL "select * from services")  
      # display available services
      echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done 
      read SERVICE_ID_SELECTED
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    done 
      BOOK_APPOINTMENT
  fi
}

BOOK_APPOINTMENT() {
  echo -e "\nYou choosed : $SERVICE_NAME"
  echo -e "\nEnter your phone number :"
  read CUSTOMER_PHONE
  echo $CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #add customer if new
  if [[ -z "$CUSTOMER_NAME" ]] 
  then
    echo -e "\nWelcome new customer ! Your name please :"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # client _id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #get appointment time
  echo -e "\nProvide the time for your appointment ?"
  read SERVICE_TIME

  # time insertion 
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirmation
  echo -e "\nAll set !"
  echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}

# Lancement du menu principal
MAIN_MENU