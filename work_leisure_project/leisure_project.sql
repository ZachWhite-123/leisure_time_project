USE leisure_time_project;
SELECT * FROM leisure;
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE leisure 
ADD COLUMN important FLOAT;

ALTER TABLE leisure 
ADD COLUMN not_important FLOAT;

UPDATE leisure
SET important = `Very important in life` + `Rather important in life`;

UPDATE leisure 
SET not_important = `Not very important in life` + `Not at all important in life`;

SELECT * FROM leisure;

ALTER VIEW `leisure_time_project`.`shared_nations` AS
	SELECT 
        `leisure_time_project`.`leisure`.`Entity` AS `Entity`,
        `leisure_time_project`.`leisure`.`Code` AS `Code`,
        `leisure_time_project`.`leisure`.`Year` AS `Year`,
        `leisure_time_project`.`leisure`.`Very important in life` AS `Very important in life`,
        `leisure_time_project`.`leisure`.`Rather important in life` AS `Rather important in life`,
        `leisure_time_project`.`leisure`.`important` AS `Important in life`,
        `leisure_time_project`.`leisure`.`Not very important in life` AS `Not very important in life`,
        `leisure_time_project`.`leisure`.`Not at all important in life` AS `Not at all important in life`,
        `leisure_time_project`.`leisure`.`not_important` AS `Not important in life`,
        `leisure_time_project`.`leisure`.`Dont know: Important in life` AS `Dont know: Important in life`,
        `leisure_time_project`.`leisure`.`No answer` AS `No answer`,
        `leisure_time_project`.`work_amount`.`avg_hours_per_capita` AS `avg_hours_per_capita`
    FROM
        (`leisure_time_project`.`leisure`
        JOIN `leisure_time_project`.`work_amount` ON (((`leisure_time_project`.`leisure`.`Entity` = `leisure_time_project`.`work_amount`.`Entity`)
            AND (`leisure_time_project`.`leisure`.`Year` = `leisure_time_project`.`work_amount`.`Year`))));

SELECT * FROM shared_nations;


-- Questions to address:

-- Question 1: What countries generally view leisure time as important?
-- 
SELECT entity, avg(`Important in life`) AS leisure_is_important, avg(`Not important in life`) AS leisure_is_not_important,
 avg(`avg_hours_per_capita`) AS avg_annual_hours FROM shared_nations
GROUP BY entity ORDER BY avg_annual_hours DESC;

--
ALTER VIEW normalized_avg_hours AS 
	WITH stats AS (
	  SELECT 
		AVG(avg_hours_per_capita) AS mean_hours,
		STDDEV(avg_hours_per_capita) AS std_hours
	  FROM shared_nations
	),
	country_avgs AS (
	  SELECT 
		entity,
		AVG(`Important in life`) AS leisure_is_important,
        AVG(`Very important in life`) AS very_important,
        AVG(`Rather important in life`) AS rather_important,
        AVG(`Not very important in life`) AS not_very_important,
        AVG(`Not at all important in life`) AS not_at_all_important,
		AVG(`Not important in life`) AS leisure_is_not_important,
		AVG(avg_hours_per_capita) AS avg_annual_hours
	  FROM shared_nations
	  GROUP BY entity
	)
	SELECT 
	  ca.entity,
	  ca.leisure_is_important,
      ca.very_important,
      ca.rather_important,
      ca.not_very_important,
      ca.not_at_all_important,
	  ca.leisure_is_not_important,
	  ca.avg_annual_hours,
	  (ca.avg_annual_hours - s.mean_hours) / s.std_hours AS normalized_hours
	FROM country_avgs ca, stats s
	ORDER BY normalized_hours DESC;
    
select * FROM normalized_avg_hours;

-- Findings / further explorations from this code chunk:
-- It seems that countries that view leisure time as being important tend to work less annually then countries that view leisure time as not important


-- Question 2: Among countries in which we have seen increases in avg_hours_per_capita over the years, have we also seen shifts in perception towards leisure time?
CREATE VIEW shifting_perception AS
	SELECT 
	  Entity,
	  Year,
	  avg_hours_per_capita,
	  `Important in life`,  -- precomputed as Very + Rather important
	  LAG(avg_hours_per_capita) OVER (PARTITION BY Entity ORDER BY Year) AS prev_avg_hours,
	  LAG(`Important in life`) OVER (PARTITION BY Entity ORDER BY Year) AS prev_important,

	  -- Calculate change from previous year
	  (avg_hours_per_capita - LAG(avg_hours_per_capita) OVER (PARTITION BY Entity ORDER BY Year)) AS delta_hours,
	  (`Important in life` - LAG(`Important in life`) OVER (PARTITION BY Entity ORDER BY Year)) AS delta_importance

	FROM shared_nations
	ORDER BY Entity, Year;

SELECT * FROM shifting_perception;
-

-- Insights from this:
-- From 2004 to 2010, Vietnam saw a significant increases in work hours yet they values leisure time less and less as they saw increases working hours
-- USA has had a relatively stable outlook on leisure despite fluctuating work hours
-- South Korea has seen a decrease in average hours worked yet has a relatively stable outlook on leisure
-- From 1993 to 1998, Chile saw a decrease in average work hours yet an increase in importance of leisure time
-- From 1994 to 2004, China saw a dramatic increase in average hours worked per year, with a somewhat fluctating outlook on importance of leisure time
-- Germany has seen a consistent decreases in hours worked per year with a relatively stable outlook on leisure time
-- Juxtaposed with China, Hong Kong saw a decrease in hours worked from 2010 to 2014, while also valuing leisure time

-- Question 3: Use window functions to get the country average displayed on each row
SELECT entity, year, `Very important in life`, `Rather important in life`,
 `Important in life`, `Not very important in life`, `Not at all important in life`, `Not important in life`, `avg_hours_per_capita`, 
 AVG(`Important in life`) OVER(PARTITION BY entity) AS important_in_life,
 AVG(`Important in life`) OVER(PARTITION BY year) AS year_avg_importance FROM shared_nations;

-- In general, it seems that nations nowadays tend to value leisure time more as years go on. 

-- Question 4: 
-- How does each countries yearly outlook compare to their average across time?
SELECT entity, year, avg(`Very important in life`), avg(`Rather important in life`),
 avg(`Important in life`), avg(`Not very important in life`), avg(`Not at all important in life`), 
 avg(`Not important in life`), avg(`avg_hours_per_capita`) 
 FROM shared_nations GROUP BY entity, year WITH ROLLUP;
 

-- Question 5: Among countries with the highest amount of work per year (sd annual_hours >1), 
-- how has there attitude towards leisure changed over the years?
CREATE VIEW hard_workers AS
	SELECT * FROM normalized_avg_hours WHERE normalized_hours >= 1;
SELECT * FROM hard_workers;

SELECT hard_workers.entity, year, leisure_is_important, leisure_is_not_important, normalized_hours, delta_hours, delta_importance
FROM hard_workers JOIN shifting_perception ON
hard_workers.entity = shifting_perception.entity;




