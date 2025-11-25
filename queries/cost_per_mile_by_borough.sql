SELECT 
  pickup_borough,
  avg((total_per_mile)) as cost_per_mile
FROM `sql-nyc-mobility-analysis.mobilty_analysis.cleaned_taxi_trips`
where 
  is_outlier_fare is false
  AND is_outlier_duration is false
  AND pickup_borough is not null
group by pickup_borough
order by cost_per_mile desc
