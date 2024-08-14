#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

function greeting(){
  echo "Enter your username:"
  read USERNAME
  # while [[ ${#USERNAME} -gt 22 || ${#USERNAME} -eq 0 ]]
  # do
  #   # keep asking for input if user provides empty string or usernames that are too long
  #   echo "The username must not be longer than 22 characters and it can't be empty. Please enter a valid username:"
  #   read USERNAME
  # done

  # check if user already exists
  USERNAME_CHECK=$($PSQL "select username from users where username='$USERNAME'")
  # USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

  if [[ -z $USERNAME_CHECK ]]
  then
    # this is a new user, greet user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # insert new user and get the user id
    INSERT_USER=$($PSQL "insert into users(username,games_played) values('$USERNAME',0)")
    USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
  else
    # this is a returning user, get games_played, best_game
    USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
    BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id=$USER_ID")
    GAMES_PLAYED=$($PSQL "select count(game_id) from games where user_id = $USER_ID;")
    # greet returning user
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

function loop()
{
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    loop
  else
    # if [[ $GUESS -lt 1 || $GUESS -gt 1000 ]]
    # then
    #   # guess is out of bounds
    #   echo "The guess must be between 1 and 1000."
    #   read GUESS
    #   loop
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      # try higher
      echo "It's higher than that, guess again:"
      read GUESS
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      loop
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      # try lower
      echo "It's lower than that, guess again:"
      read GUESS
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      loop
    else
      # win, you guessed the number
      # increment games count and guesses count
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      # update db
      INSERT_NEW_GAME=$($PSQL "insert into games(user_id,number_of_guesses) values($USER_ID, $NUMBER_OF_GUESSES)")
      # print to console
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}