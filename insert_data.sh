#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Optional reset so reruns stay clean
$PSQL "TRUNCATE games, teams;"

while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID=$($PSQL "WITH ins AS (
      INSERT INTO teams(name)
      VALUES('$WINNER')
      ON CONFLICT (name) DO NOTHING
      RETURNING team_id
    )
    SELECT team_id FROM ins
    UNION
    SELECT team_id FROM teams WHERE name='$WINNER'
    LIMIT 1;")

    OPPONENT_ID=$($PSQL "WITH ins AS (
      INSERT INTO teams(name)
      VALUES('$OPPONENT')
      ON CONFLICT (name) DO NOTHING
      RETURNING team_id
    )
    SELECT team_id FROM ins
    UNION
    SELECT team_id FROM teams WHERE name='$OPPONENT'
    LIMIT 1;")

    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
  fi
done < games.csv
