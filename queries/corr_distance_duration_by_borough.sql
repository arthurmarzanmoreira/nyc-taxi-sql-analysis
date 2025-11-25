SELECT
  pickup_borough,
  CORR(trip_distance, trip_duration_min) AS corr_distance_duration
FROM `sql-nyc-mobility-analysis.mobilty_analysis.cleaned_taxi_trips`
WHERE NOT (is_outlier_speed OR is_outlier_fare OR is_outlier_duration)
group by pickup_borough
order by corr_distance_duration desc
