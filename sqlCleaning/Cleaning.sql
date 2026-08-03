-- Working and cleaning the data in the air_quality_historical table.


-- Select top 10 rows from the air_quality_historical table
Select top 10 * from air_quality_historical


Select count(*) from air_quality_historical

--- This will find the top 3 cities with highest AQI recorded 
SELECT Distinct top 3 City, Max(AQI) FROM air_quality_historical
group by city 
order by Max(aqi) DESC
--- Ahmedabad, Guwahati, Gurugram are the three cities where the AQI found the highest


-- Find rows where all specified columns are NULL
SELECT * FROM [dbo].[air_quality_historical] 
WHERE  COALESCE(
    pm25, pm10, no, no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket
  ) IS NULL;


-- Count rows where all specified columns are NULL
SELECT COUNT(*) FROM [dbo].[air_quality_historical] 
WHERE  COALESCE(
    pm25, pm10, no, no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket
  ) IS NULL;


-- Find rows where aqi is NULL
SELECT * FROM [dbo].[air_quality_historical] 
WHERE aqi IS Not NULL;


-- Count the number of rows where all specified columns are null after the cleanup
SELECT COUNT(*) FROM [dbo].[air_quality_historical] 
WHERE  COALESCE(
    pm25, pm10, no, no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket
  ) IS NULL;


-- Delete rows where all specified columns are NULL because they don't provide any useful information for analysis
DELETE FROM [dbo].[air_quality_historical] 
WHERE  COALESCE(
    pm25, pm10, no, no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket
  ) IS NULL;


-- Count the number of rows where all specified columns are null
-- This helps in identifying rows that do not contribute to the analysis
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN aqi IS NULL THEN 1 ELSE 0 END) AS aqi_nulls,
    SUM(CASE WHEN pm25 IS NULL THEN 1 ELSE 0 END) AS pm25_nulls,
    SUM(CASE WHEN pm10 IS NULL THEN 1 ELSE 0 END) AS pm10_nulls,
    SUM(CASE WHEN no2 IS NULL THEN 1 ELSE 0 END) AS no2_nulls,
    SUM(CASE WHEN so2 IS NULL THEN 1 ELSE 0 END) AS so2_nulls,
    SUM(CASE WHEN co IS NULL THEN 1 ELSE 0 END) AS co_nulls,
    SUM(CASE WHEN o3 IS NULL THEN 1 ELSE 0 END) AS o3_nulls
   
FROM air_quality_historical;


-- Benzene, toulene and xylene are not used in the Indian official standards according to CPCB. 
-- So, we will set them to NULL if they are 0.
-- and also if any other columns has zero values, we will set them to NULL as well because 0 is not a valid value for these pollutants.
UPDATE air_quality_historical
SET benzene = NULL
WHERE benzene = 0;

UPDATE air_quality_historical
SET toluene = NULL
WHERE toluene = 0;

UPDATE air_quality_historical
SET xylene = NULL
WHERE xylene = 0;

UPDATE air_quality_historical
SET pm25 = NULL
WHERE pm25 = 0;

UPDATE air_quality_historical
SET pm10 = NULL
WHERE pm10 = 0;

UPDATE air_quality_historical
SET no = NULL
WHERE no = 0;

UPDATE air_quality_historical
SET no2 = NULL
WHERE no2 = 0;

UPDATE air_quality_historical
SET nox = NULL
WHERE nox = 0;

UPDATE air_quality_historical
SET nh3 = NULL
WHERE nh3 = 0;

UPDATE air_quality_historical
SET co = NULL
WHERE co = 0;

UPDATE air_quality_historical
SET so2 = NULL
WHERE so2 = 0;

UPDATE air_quality_historical
SET o3 = NULL
WHERE o3 = 0; 



--Now again remove the rows where all columns are because we have just updated some columns to NULL.
DELETE FROM [dbo].[air_quality_historical]
WHERE  COALESCE(
    pm25, pm10, no, no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket
  ) IS NULL;

--- Now the rest no. of rows are 27246, removed around 2000 rows which were not useful for analysis.
SELECT COUNT(*) FROM [dbo].[air_quality_historical];


-- there are 24850 rows with AQI not null and not equal to 0, which is good for analysis.
select count(*) from [dbo].[air_quality_historical]
where aqi is not null and aqi != 0;


-- Count the number of rows where aqi is not null and aqi_bucket is null
-- The Ans is 0, which means all the rows with aqi not null have aqi_bucket not null as well.
SELECT COUNT(*) FROM air_quality_historical 
WHERE aqi IS NOT NULL AND aqi_bucket IS NULL;

-- PM 2.5 should not be greater than PM 10 as this represents the particle size, but there are 256 rows where this is not the case.
-- So we will update them as NULL because they are not valid data points.
SELECT COUNT(*) FROM air_quality_historical 
WHERE pm25 > pm10;

-- Making them as NULL because they are not valid data points.
UPDATE air_quality_historical
SET pm25 = NULL
WHERE pm25 > pm10;

-- This will count the number of rows where there are duplicate entries for the same city and same date. 
-- Means same city and same date repeated more than once
SELECT city, [date], COUNT(*) as cnt 
FROM air_quality_historical 
GROUP BY city, [date] 
HAVING COUNT(*) > 1;

-- This will count the number of rows where aqi is less than 0 or greater than 1000
-- There are only 2 rows with aqi 1900+ this is likely very rare possibility or a error
-- The highest AQI value ever recorded in India is 494 but there are 543 rows with aqi greater than 500, 
-- But for some rare cases it is possible to have these kind of AQI spikes because of festivals like diwali or other reasons
-- so the final threshold will be 1500 so that only those will get removed which are very rare and likely to be errors.
SELECT COUNT(*) FROM air_quality_historical
WHERE aqi < 0 OR aqi > 1500;

-- So here we have updated the error AQI values to NULL
UPDATE air_quality_historical
SET aqi = NULL
WHERE aqi > 1500 OR aqi < 0;


--- Working and cleaning the data in the air_quality_recent table.

--- This will count max and min aqi values from air_quality_recent will help us in identifying the outliers and cleaning the data.
SELECT MIN(aqi_value) AS min_val, MAX(aqi_value) AS max_val 
FROM air_quality_recent;
--- Max value is 500 and min value is 3 


--- This will count the number of rows where there are duplicate entries for the same area and same date.
SELECT [date], area, COUNT(*) as count 
FROM air_quality_recent 
GROUP BY [date], area, [state]
HAVING COUNT(*) > 1;
--- There is no outliers in the air_quality_recent table but there is some duplicate rows


--- But later found out that the same name and date clashed but these are two different states, Aurangabad(Maharastra) and Aurangabad(Bihar)
SELECT * FROM air_quality_recent 
WHERE [date] = '2022-04-01' AND area = 'Aurangabad'
ORDER BY [date]; 
--- so there are no duplicates


SELECT COUNT(*) AS total_rows FROM air_quality_recent;

SELECT COUNT(*) AS fully_null_rows
FROM air_quality_recent 
WHERE COALESCE(number_of_monitoring_stations, prominent_pollutants, aqi_value, air_quality_status) IS NULL;

--- There is no null values inside air_quality_recent table.
SELECT COUNT(*) AS fully_null_rows
FROM air_quality_recent 
WHERE COALESCE(date, state, area) IS NULL;
--- There is no null values inside air_quality_recent table.

Select * from air_quality_recent
--- This will tell the unique status values of both the data sets
select Distinct air_quality_status from
air_quality_recent

select Distinct AQI_bucket
from air_quality_historical 

select * from air_quality_hourly

SELECT COUNT(*) AS fully_null_rows
FROM air_quality_hourly
WHERE COALESCE(pm25, pm10, [no], no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket) IS NULL;
--- There are 50292 rows where all the columns are null in air_quality_hourly table.
--- so we will delete those rows because they don't provide any useful information for analysis.

DELETE FROM air_quality_hourly
WHERE COALESCE(pm25, pm10, [no], no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket) IS NULL;
--- rows deleted successfully, now there are 657583 rows in the air_quality_hourly table.


--- Now we are going to update the values in each column with the value is '0' to NULL
UPDATE air_quality_hourly SET pm25 = NULL 
WHERE pm25 = 0;

UPDATE air_quality_hourly SET pm10 = NULL 
WHERE pm10 = 0;

UPDATE air_quality_hourly SET [no] = NULL 
WHERE [no] = 0;

UPDATE air_quality_hourly SET no2 = NULL
 WHERE no2 = 0;

UPDATE air_quality_hourly SET nox = NULL
 WHERE nox = 0;

UPDATE air_quality_hourly SET nh3 = NULL 
WHERE nh3 = 0;

UPDATE air_quality_hourly SET co = NULL 
WHERE co = 0;

UPDATE air_quality_hourly SET so2 = NULL 
WHERE so2 = 0;

UPDATE air_quality_hourly SET o3 = NULL 
WHERE o3 = 0;

UPDATE air_quality_hourly SET benzene = NULL 
WHERE benzene = 0;

UPDATE air_quality_hourly SET toluene = NULL
 WHERE toluene = 0;

UPDATE air_quality_hourly SET xylene = NULL 
WHERE xylene = 0;
--- Updated '0' to "NULL"


--- we are again going to find any entire null row/ rows and if there is any then we will remove it.
SELECT COUNT(*) AS fully_null_rows
FROM air_quality_hourly
WHERE COALESCE(pm25, pm10, [no], no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket) IS NULL;
--- There are again 21642 fully NULL rows 

DELETE FROM air_quality_hourly
WHERE COALESCE(pm25, pm10, [no], no2, nox, nh3, co, so2, o3, benzene, toluene, xylene, aqi, aqi_bucket) IS NULL;

Select count(*) from air_quality_hourly
--- Now there are 635941 rows left.


SELECT MIN(aqi) AS min_aqi, MAX(aqi) AS max_aqi FROM air_quality_hourly
--- Min aqi is 3 and Max aqi is 3133. Min is good but this is max value is not possible.


SELECT COUNT(*) FROM air_quality_hourly WHERE aqi > 2000;
--- There are 748 rows where AQI is greater than 2000, this much AQI value is practically not possible.


--- This query will check check the distribution of three ranges so taht we can grt a clear picture. 
SELECT 
    SUM(CASE WHEN aqi > 500 AND aqi <= 1000 THEN 1 ELSE 0 END) AS range_500_to_1000,
    SUM(CASE WHEN aqi > 1000 AND aqi <= 2000 THEN 1 ELSE 0 END) AS range_1000_to_2000,
    SUM(CASE WHEN aqi > 2000 THEN 1 ELSE 0 END) AS above_2000
FROM air_quality_hourly;

--- We have taken the threshold 1500 as we have taken in historical data table.
UPDATE air_quality_hourly
SET aqi = NULL
WHERE aqi > 1500;

--- This will NULL the aqi Bucket where AQI is already null but having some value in bucket like 'Poor', 'Good', etc
UPDATE air_quality_hourly
SET aqi_bucket = NULL
WHERE aqi IS NULL AND aqi_bucket IS NOT NULL;


-- PM 2.5 should not be greater than PM 10 as this represents the particle size but there are 7013 rows where this anomaly happens
SELECT COUNT(*) AS pm25_gt_pm10 FROM air_quality_hourly WHERE pm25 > pm10;

--- we have updated the values to NULL
UPDATE air_quality_hourly
SET pm25 = NULL
WHERE pm25 > pm10;

--- Now we are checking for the stations Data
Select * from stations

-- 1. Fully null / missing city
SELECT COUNT(*) AS missing_city FROM stations WHERE city IS NULL OR city = '';
--- Found 0 missing and NULL cities

-- 2. Duplicate station_id check
SELECT station_id, COUNT(*) as cnt 
FROM stations 
GROUP BY station_id 
HAVING COUNT(*) > 1;
--- There is no duplicate


-- 3. Status column check
SELECT DISTINCT status FROM stations;
--- There are 'Active', 'Inactive', and 'NULL'. Which shows the activity status of the stations.

-- 4. City name consistency check 
SELECT DISTINCT city FROM stations ORDER BY city;


SELECT Count(DISTINCT [state]) FROM stations ;



SELECT DISTINCT [state] FROM stations ;
--- There are 21 states that we have the data of and we are going to work on these 21 states data.


--- This query will UNION two tables to show that full film of the data from 2015 to 2025.
--- we have created a VIEW so that we can store the new table in that VIEW and call it when ever needed.
CREATE VIEW v_aqi_unified AS
SELECT
    [date],
    city AS city_name,
    aqi AS aqi_value,
    aqi_bucket AS air_quality_status,
    'historical' AS source_period
FROM air_quality_historical
WHERE aqi IS NOT NULL

UNION ALL

SELECT
    [date],
    area AS city_name,
    aqi_value,
    air_quality_status,
    'recent' AS source_period
FROM air_quality_recent;

SELECT source_period, COUNT(*) AS cnt FROM v_aqi_unified;

SELECT * FROM v_aqi_unified WHERE city_name = 'Delhi' ORDER BY [date];

