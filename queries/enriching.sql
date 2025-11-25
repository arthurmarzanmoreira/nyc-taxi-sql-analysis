CREATE TABLE `sql-nyc-mobility-analysis.mobilty_analysis.cleaned_taxi_trips` AS
SELECT
  -- base fields (from public source, with your names)
  pickup_datetime,
  dropoff_datetime,
  timestamp_diff(dropoff_datetime, pickup_datetime, minute) AS trip_duration_min,
  passenger_count,
  trip_distance,
  fare_amount,
  tip_amount,
  total_amount,
  pickup_location_id,
  dropoff_location_id,

  -- time helpers
  EXTRACT(HOUR      FROM pickup_datetime)       AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime)       AS pickup_weekday,  -- 1=Sun..7=Sat
  EXTRACT(MONTH     FROM pickup_datetime)       AS pickup_month,
  EXTRACT(YEAR      FROM pickup_datetime)       AS pickup_year,
  CASE WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) IN (1,7)
       THEN TRUE ELSE FALSE END                 AS is_weekend,

  -- fare/tip behavior & efficiency
  SAFE_DIVIDE(tip_amount,  fare_amount)  * 100  AS tip_percent,
  SAFE_DIVIDE(tip_amount,  trip_distance)       AS tip_per_mile,
  SAFE_DIVIDE(total_amount,trip_distance)       AS total_per_mile,
  SAFE_DIVIDE(trip_distance, timestamp_diff(dropoff_datetime, pickup_datetime, minute)) * 60 AS avg_speed_mph,

  -- buckets
  CASE
    WHEN trip_distance < 1  THEN 'Under 1 mi'
    WHEN trip_distance < 5  THEN '1–4 mi'
    WHEN trip_distance < 10 THEN '5–9 mi'
    ELSE '10+ mi'
  END AS distance_bucket,
  CASE
    WHEN timestamp_diff(dropoff_datetime, pickup_datetime, minute) < 10 THEN 'Short (<10m)'
    WHEN timestamp_diff(dropoff_datetime, pickup_datetime, minute) < 30 THEN 'Medium (10–29m)'
    WHEN timestamp_diff(dropoff_datetime, pickup_datetime, minute) < 60 THEN 'Long (30–59m)'
    ELSE 'Very Long (60m+)'
  END AS duration_bucket,

  -- geography (join once for pickup, once for dropoff)
  pu.borough   AS pickup_borough,
  pu.zone_name AS pickup_zone,
  do.borough   AS dropoff_borough,
  do.zone_name AS dropoff_zone,

  -- simple anomaly flags (repeat expression so alias timing isn’t an issue)
  CASE
    WHEN SAFE_DIVIDE(trip_distance, timestamp_diff(dropoff_datetime, pickup_datetime, minute)) * 60 < 2
    OR SAFE_DIVIDE(trip_distance, timestamp_diff(dropoff_datetime, pickup_datetime, minute)) * 60 > 60
    THEN TRUE ELSE FALSE
  END AS is_outlier_speed,
  CASE 
    WHEN total_amount < 1 
    OR total_amount > 300 
    THEN TRUE ELSE FALSE 
  END  AS is_outlier_fare,
  CASE 
    WHEN timestamp_diff(dropoff_datetime, pickup_datetime, minute) < 1 
    OR timestamp_diff(dropoff_datetime, pickup_datetime, minute) > 180 
    THEN TRUE ELSE FALSE 
  END AS is_outlier_duration

FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` src
LEFT JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` pu
  ON src.pickup_location_id  = pu.zone_id
LEFT JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` do
  ON src.dropoff_location_id = do.zone_id

WHERE
  trip_distance > 0 AND trip_distance < 100
  AND timestamp_diff(dropoff_datetime, pickup_datetime, minute) BETWEEN 1 AND 180
  AND fare_amount > 0.01 AND fare_amount < 300
  AND passenger_count BETWEEN 1 AND 6;
