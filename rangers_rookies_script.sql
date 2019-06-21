-- make rookies table

create table nhl_rookies (
	player_rank integer,
	player varchar(32),
	goals integer,
	team char(3),
	league char(32),
	posistion varchar(2),
	season text,
	age integer,
	games_played integer,
	assists integer,
	points integer,
	rating integer,
	pim integer,
	even_strength_points integer,
	power_play_points integer,
	short_handed_points integer,
	game_winning_goals integer,
	shots_on_goal integer,
	shooting_perc numeric(3,1),
	ice_time integer,
	goals_per_game numeric(3,2),
	assists_per_game numeric(3,2),
	points_per_game numeric(3,2),
	shots_per_game numeric(3,2)
);

-- fill table with data from hockey-reference.com


copy nhl_rookies
from '/Users/aidanbarr/Downloads/NHL_rookies_20102018.csv'
delimiter ',';

-- fix table issue by changing the datatype for a column

alter table nhl_rookies
alter column player_rank
type integer;

-- remove unnecessary column 

alter table nhl_rookies
DROP rank;

-- check to make sure data is in table

select *
from nhl_rookies;

-- make sure table query works

select *
from nhl_rookies
where player = 'Filip Chytil';

-- interesting stat

select AVG(games_played)
from nhl_rookies;

-- created identical tables for the game logs of Lias Andersson, Filip Chytil, and Brett Howden

create table L_andersson_gamelog_2018 (
	game_number integer,
	game_date date,
	game integer,
	age text,
	team char(3),
	status text,
	opponent char(3),
	game_result text,
	goals integer,
	assists integer,
	points integer,
	rating integer,
	penalty_minutes integer,
	ev_goals integer,
	pp_points integer,
	sh_points integer,
	gw_goals integer,
	ev_assists integer,
	pp_assists integer,
	sh_assists integer,
	shots_on_goal integer,
	shooting_perc numeric(4,1),
	n_shifts integer,
	ice_time text,
	hits integer,
	blk_shots integer,
	faceoff_w integer,
	faceoff_l integer,
	faceoff_perc numeric(4,1)
);

select *
from chytil_gamelog_2018;

--add data to each game log table

copy L_andersson_gamelog_2018
from '/Users/aidanbarr/Downloads/l_andersson_gamelog_2018.csv'
delimiter ',' csv HEADER;

-- fix error in creating table for filip chytil

alter table chytil_gamelog_2018
alter column faceoff_perc 
type numeric(4,1);

-- check data quality in each table
	
select *
from l_andersson_gamelog_2018;

-- drop unnecessary column in 

alter table l_andersson_gamelog_2018
drop column game_number;

-- finding an interesting fact for fun!

select c.game_date, game, c.points as chytil_points, a.points as andersson_points, h.points as howden_points
from chytil_gamelog_2018 as c
inner join l_andersson_gamelog_2018 as a
using (game)
inner join howden_gamelog_2018 as h
using (game);

-- adding a column to each table with the players name

alter table chytil_gamelog_2018
add column player varchar(32);

-- check to see column

select player
from chytil_gamelog_2018;

-- add name to column

update chytil_gamelog_2018 set player = 'Filip Chytil';

-- check data

select player
from chytil_gamelog_2018;

select *
from chytil_gamelog_2018;

-- now do the same for howden and andersson

alter table howden_gamelog_2018
add column player varchar(32);

update howden_gamelog_2018 set player = 'Brett Howden';

alter table chytil_gamelog_2018
add column id serial primary KEY;

update l_andersson_gamelog_2018 set player = 'Lias Andersson';

select *
from l_andersson_gamelog_2018;

select *
from chytil_gamelog_2018;

delete from chytil_gamelog_2018
where id = 76;

delete from howden_gamelog_2018
where game = null;

-- data is ready to be imported into R for analysis



	
	
	