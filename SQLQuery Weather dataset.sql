select * from dbo.weather_data_cleaned;

/*1)*/
WITH daily_temp AS (
  SELECT Date, Average_temperature,
         LAG(Average_temperature) OVER (ORDER BY Date) AS prev_temp
  FROM dbo.weather_data_cleaned)
  
SELECT COUNT(*) as minimumdays
FROM daily_temp
WHERE Average_temperature < prev_temp;

/*2)*/
ALTER TABLE dbo.weather_data_cleaned
ALTER COLUMN Average_temperature float;

With CTE as 
(SELECT Date, Average_temperature from dbo.weather_data_cleaned)
Select Date, Average_temperature,
CASE 
    WHEN Average_temperature >= AVG(Average_temperature) over() THEN 'Hot'
    ELSE 'Cold'
END as 'temp_status'
FROM CTE;


/*3)*/
WITH CTE AS (
   SELECT 
     Date, 
     Average_temperature, 
     Case 
        When Average_temperature < 30 then 'below'
        else 'above'
     end as temp30,
     ROW_NUMBER() OVER (ORDER BY Date) AS RowNumber
   FROM dbo.weather_data_cleaned
)
SELECT 
  CTE.Date, 
  CTE.Average_temperature, 
  CTE.temp30 
FROM CTE
WHERE temp30 = 'below'
  AND (
    SELECT COUNT(*) 
    FROM CTE as innerCTE 
    WHERE innerCTE.RowNumber BETWEEN CTE.RowNumber AND CTE.RowNumber + 3
      AND innerCTE.temp30 = 'below'
  ) = 4
ORDER BY CTE.Date;


/*4)*/
WITH Temperatures AS (
  SELECT Date, Average_temperature, 
         LAG(Average_temperature) OVER (ORDER BY Date) AS prev_temp,
         ROW_NUMBER() OVER (ORDER BY Date) AS row_num
  FROM dbo.weather_data_cleaned
), drops AS (
  SELECT date, Average_temperature, prev_temp, row_num,
         SUM(CASE WHEN Average_temperature < prev_temp THEN 1 ELSE 0 END) 
           OVER (ORDER BY row_num ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS count_drops
  FROM Temperatures
)
SELECT MAX(count_drops)
FROM drops;



/*5)*/
ALTER TABLE dbo.weather_data_cleaned
ALTER COLUMN Average_humidity float;
SELECT AVG(avg_humidity) as avgofavg_humidity
FROM (
  SELECT Date, AVG(Average_humidity) as avg_humidity
  FROM dbo.weather_data_cleaned
  GROUP BY Date
) as Temp;


/*6)*/
ALTER TABLE dbo.weather_data_cleaned
ALTER COLUMN Average_windspeed float;
SELECT  Date, 
AVG(Average_windspeed) as avg_windspeed
FROM dbo.weather_data_cleaned
GROUP BY Date;



/*8)*/
ALTER TABLE dbo.weather_data_cleaned
ALTER COLUMN Maximum_gust_speed float;
WITH wind AS (
  SELECT Date,  Maximum_gust_speed, 
         LAG( Maximum_gust_speed) OVER (ORDER BY date) AS prev_max_gust_speed,
         ROW_NUMBER() OVER (ORDER BY Date) AS row_num
  FROM dbo.weather_data_cleaned
)
SELECT Date,  Maximum_gust_speed
FROM wind
WHERE  Maximum_gust_speed > 55 
  AND prev_max_gust_speed <= 55;


/*9)*/
ALTER TABLE dbo.weather_data_cleaned
ALTER COLUMN Minimum_temperature float;
select count(Date)
from dbo.weather_data_cleaned
where Minimum_temperature<0;










