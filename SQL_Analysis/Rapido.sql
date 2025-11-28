CREATE DATABASE rapido_rides;
use rapido_rides;

-- ||BASIC
-- 1.View all ride records:
select * from rides_data;

-- 2.List all unique services offered:
SELECT DISTINCT services FROM rides_data;

-- 3.Count total rides:
SELECT COUNT(*) AS total_rides FROM rides_data;

-- 4.Show only completed rides:
SELECT * FROM rides_data WHERE ride_status = 'completed';

-- 5.Find rides paid via Amazon Pay:
SELECT * FROM rides_data WHERE payment_method = 'Amazon Pay';

-- 6.Sort rides by highest fare:
SELECT * FROM rides_data ORDER BY total_fare DESC;

-- 7.Find all cancelled rides:
SELECT * FROM rides_data WHERE ride_status = 'cancelled';

-- 8.Show rides longer than 60 minutes:
SELECT ride_id, duration, total_fare FROM rides_data WHERE duration > 60;

-- 9.List rides where total fare > 500:
SELECT ride_id, services, total_fare FROM rides_data WHERE total_fare > 500;

-- 10.Display rides that started after 6 PM:
SELECT ride_id, time, total_fare FROM rides_data WHERE HOUR(time) >= 18;

-- 11.Find rides with missing total fare (null values):
SELECT * FROM rides_data WHERE total_fare IS NULL;

-- Show all rides starting from ‘Basavanagudi 3rd Block’:
SELECT * FROM rides_data WHERE source = 'Basavanagudi 3rd Block';

-- 12.List first 10 rides ordered by distance (ascending):
SELECT ride_id, distance, total_fare FROM rides_data ORDER BY distance ASC LIMIT 10;

-- 13.Show distinct pickup locations (sources):
SELECT DISTINCT source FROM rides_data;

-- 14.Count total number of cancelled rides:
SELECT COUNT(*) AS cancelled_rides FROM rides_data WHERE ride_status = 'cancelled';

-- 15.Check minimum and maximum total fare:
SELECT MIN(total_fare) AS min_fare, MAX(total_fare) AS max_fare FROM rides_data;

-- ||INTERMEDIATE
-- 1.Average fare by service type:
SELECT services, AVG(total_fare) AS avg_fare
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY services;

-- 2.Total rides per payment method:
SELECT payment_method, COUNT(*) AS total_rides
FROM rides_data
GROUP BY payment_method
ORDER BY total_rides DESC;

-- 3.Top 5 longest rides (by duration):
SELECT ride_id, services, duration, total_fare
FROM rides_data
ORDER BY duration DESC
LIMIT 5;

-- 4.Cancelled rides count per month:
SELECT MONTH(date) AS month_no, COUNT(*) AS cancelled_rides
FROM rides_data
WHERE ride_status = 'cancelled'
GROUP BY MONTH(date)
ORDER BY month_no;

-- 5.Average distance and fare by ride status:
SELECT ride_status,
       ROUND(AVG(distance),2) AS avg_distance,
       ROUND(AVG(total_fare),2) AS avg_fare
FROM rides_data
GROUP BY ride_status;

-- 6.Count rides per ride_status:
SELECT ride_status, COUNT(*) AS total_rides FROM rides_data GROUP BY ride_status;

-- 7.Average total fare per payment method:
SELECT payment_method, ROUND(AVG(total_fare),2) AS avg_fare
FROM rides_data
WHERE total_fare IS NOT NULL
GROUP BY payment_method;

-- 8.Total revenue (sum of fares) per service type:
SELECT services, ROUND(SUM(total_fare),2) AS total_revenue
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY services
ORDER BY total_revenue DESC;

-- 9.Identify rides with above-average fare:
SELECT ride_id, total_fare
FROM rides_data
WHERE total_fare > (SELECT AVG(total_fare) FROM rides_data);

-- 10.Number of rides completed each day:
SELECT date, COUNT(*) AS rides_completed
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY date
ORDER BY date;

-- 11.Total fare collected per month:
SELECT MONTH(date) AS month_no, SUM(total_fare) AS total_monthly_fare
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY MONTH(date)
ORDER BY month_no;

-- 12.Average distance covered by each service type:
SELECT services, ROUND(AVG(distance),2) AS avg_distance
FROM rides_data
GROUP BY services;

-- 13.Show routes with more than 3 rides:
SELECT source, destination, COUNT(*) AS route_count
FROM rides_data
GROUP BY source, destination
HAVING COUNT(*) > 3;

-- 14.Average ride duration by payment method:
SELECT payment_method, ROUND(AVG(duration),2) AS avg_duration
FROM rides_data
GROUP BY payment_method;

-- 15.Cancelled rides per payment method:
SELECT payment_method, COUNT(*) AS cancelled_rides
FROM rides_data
WHERE ride_status = 'cancelled'
GROUP BY payment_method;

-- ||ADVANCED
-- 1.Find top 3 high-paying routes (source → destination):
SELECT source, destination, ROUND(AVG(total_fare),2) AS avg_fare
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY source, destination
ORDER BY avg_fare DESC
LIMIT 3;

-- 2.Identify the busiest routes (highest ride count):
SELECT source, destination, COUNT(*) AS total_rides
FROM rides_data
GROUP BY source, destination
ORDER BY total_rides DESC
LIMIT 5;

-- 3.Compare average fare by time of day (Morning/Afternoon/Night):
SELECT
  CASE
    WHEN HOUR(time) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Night'
  END AS time_period,
  ROUND(AVG(total_fare),2) AS avg_fare
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY time_period;

-- 4.Find customers who had repeated routes (same source & destination):
SELECT source, destination, COUNT(*) AS ride_count
FROM rides_data
GROUP BY source, destination
HAVING ride_count > 1
ORDER BY ride_count DESC;

-- 5.Detect possible anomalies (very long duration but low fare):
SELECT ride_id, services, duration, total_fare
FROM rides_data
WHERE duration > 60 AND total_fare < 200;

-- 6.Find top 3 rides by total fare for each service type:
SELECT *
FROM (
    SELECT ride_id, services, total_fare,
           RANK() OVER (PARTITION BY services ORDER BY total_fare DESC) AS rank_no
    FROM rides_data
) ranked
WHERE rank_no <= 3;

-- 7.Identify top 5 pickup locations generating the most revenue:
SELECT source, SUM(total_fare) AS total_revenue
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY source
ORDER BY total_revenue DESC
LIMIT 5;

-- 8.Show the % of cancelled rides for each service:
SELECT 
    services,
    ROUND(SUM(CASE WHEN ride_status='cancelled' THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS cancel_rate
FROM rides_data
GROUP BY services;

-- 9.Find the hour of the day with maximum rides:
SELECT HOUR(time) AS ride_hour, COUNT(*) AS total_rides
FROM rides_data
GROUP BY HOUR(time)
ORDER BY total_rides DESC
LIMIT 1;

-- 10.Compare performance (average fare & duration) between cab and auto:
SELECT services,
       ROUND(AVG(total_fare),2) AS avg_fare,
       ROUND(AVG(duration),2) AS avg_duration
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY services;

-- 11.Find rides where total_fare differs from (ride_charge + misc_charge):
SELECT ride_id, ride_charge, misc_charge, total_fare,
       (ride_charge + misc_charge) AS calculated_total
FROM rides_data
WHERE ROUND(ride_charge + misc_charge,2) <> ROUND(total_fare,2);

-- 12.Identify routes with the highest average fare per km:
SELECT source, destination,
       ROUND(AVG(total_fare / distance),2) AS avg_fare_per_km
FROM rides_data
WHERE distance > 0 AND ride_status = 'completed'
GROUP BY source, destination
ORDER BY avg_fare_per_km DESC
LIMIT 5;

-- 13.Find monthly fare growth using window functions:
SELECT 
    MONTH(date) AS month_no,
    SUM(total_fare) AS monthly_fare,
    ROUND(
      SUM(total_fare) - LAG(SUM(total_fare)) OVER (ORDER BY MONTH(date)), 2
    ) AS growth
FROM rides_data
WHERE ride_status = 'completed'
GROUP BY MONTH(date);

-- 14.Find rides whose fare is greater than average fare for that payment method:
SELECT r.ride_id, r.payment_method, r.total_fare
FROM rides_data r
JOIN (
    SELECT payment_method, AVG(total_fare) AS avg_fare
    FROM rides_data
    GROUP BY payment_method
) avg_table
ON r.payment_method = avg_table.payment_method
WHERE r.total_fare > avg_table.avg_fare;

-- 15.Identify underperforming services (lowest revenue & high cancellations):
SELECT services,
       SUM(CASE WHEN ride_status='completed' THEN total_fare ELSE 0 END) AS total_revenue,
       ROUND(SUM(CASE WHEN ride_status='cancelled' THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS cancel_rate
FROM rides_data
GROUP BY services
ORDER BY total_revenue ASC, cancel_rate DESC;