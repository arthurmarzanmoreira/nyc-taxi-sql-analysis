SELECT
  pickup_borough,
  avg(total_amount) as avg_total_fare,
  avg(tip_percent) as avg_tip_percent
FROM
  `sql-nyc-mobility-analysis.mobilty_analysis.cleaned_taxi_trips`
where 
  pickup_borough is not null
  AND is_outlier_fare is false
group by pickup_borough
order by avg_total_fare
