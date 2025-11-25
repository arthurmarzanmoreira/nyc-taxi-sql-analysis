CREATE OR REPLACE TABLE `sql-nyc-mobility-analysis.mobilty_analysis.cleaned_taxi_trips` AS
SELECT 
  pickup_datetime,
  dropoff_datetime,
  timestamp_diff(dropoff_datetime, pickup_datetime, minute) AS trip_duration_min,
  passenger_count,
  trip_distance,
  fare_amount,
  tip_amount,
  total_amount,
  pickup_location_id,
  dropoff_location_id
FROM 
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` 
WHERE 
  (trip_distance > 0 
    AND trip_distance < 100)
  AND (timestamp_diff(dropoff_datetime, pickup_datetime, minute) BETWEEN 1 AND 180) 
  AND (fare_amount > 0.01
        AND fare_amount < 300)
  AND (passenger_count > 0 
        AND passenger_count < 7)
