--- In this exercise, you will retrieve information about matches played between Barcelona (id = 8634) and Real Madrid (id = 8633).

SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as away,
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
        WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
        ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);


--- Your goal here is to use the country and match table to determine the total number of matches
--- won by the home team in each country during the 2012/2013, 2013/2014, and 2014/2015 seasons.

SELECT 
	c.name AS country,
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP BY name;


--- Your task is to examine the number of wins, losses, and ties in each country. 
--- The matches table is filtered to include all matches from the 2013/2014 and 2014/2015 seasons.

SELECT 
	c.name AS country,
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

--- How do you get both the home and away team names into one final query result?

SELECT
	m.date,
	home.hometeam,
	away.awayteam,
	m.home_goal,
   	m.away_goal
FROM match AS m
-- Join the home subquery to the match table
LEFT JOIN (
  	SELECT match.id, team.team_long_name AS hometeam
  	FROM match
  	LEFT JOIN team
  	ON match.hometeam_id = team.team_api_id) AS home
ON home.id = m.id
-- Join the away subquery to the match table
LEFT JOIN (
 	SELECT match.id, team.team_long_name AS awayteam
  	FROM match
  	LEFT JOIN team
  	ON match.awayteam_id = team.team_api_id) AS away
ON away.id = m.id;


