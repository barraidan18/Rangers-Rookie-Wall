# Rangers-Rookie-Wall

The code I used to analyze the scoring of Rangers Rookies.

#Motivation

I was interested to see if any Rangers Rookies hit what is commonly refered to as the "rookie wall". The "rookie wall" is a common phrase in Hockey for when rookies in the NHL start to struggle in the middle or towards the end of the NHL regular season because they are not used to the length and difficulty of the season.

![Filip Chytil](https://github.com/barraidan18/Rangers-Rookie-Wall/blob/master/Filip%20Chytil%20points%20per%20hour%20plot%202018.png)

Start by importing all the relevant data into SQL tables. It is possible to import the data directly into R but having the data an SQL database is useful.

![SQL code](https://github.com/barraidan18/Rangers-Rookie-Wall/blob/master/rangers_rookies_script.sql)

Here is the R code to make the conection to the PosgreSQL database, query it and then analyze the data.



