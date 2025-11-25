NYC Taxi Mobility Analysis — SQL Case Study

BigQuery • SQL • 35M rows • Data Cleaning • Feature Engineering • Exploratory Analysis

This project analyzes New York City taxi mobility patterns using the TLC Trip Record Data (public dataset hosted in BigQuery).
The goal was to perform end-to-end data cleaning, enrichment, and exploratory analysis using SQL only, focusing on realistic business-style questions.

This project is intentionally SQL-only to demonstrate comfort with large datasets, query logic, and analytical reasoning.
A separate visualization project (Tableau) will come from a smaller dataset in the Google Data Analytics Certificate.

⸻

Business Questions

This analysis answers the following:

1. Demand Patterns
	•	How do trip volumes vary by hour, day of week, and month?
	•	When are peak and off-peak periods?

2. Geographic Trends
	•	Which boroughs have the most pickups and dropoffs?
	•	What are the most common pickup → dropoff flows?

3. Fare & Tip Behavior
	•	How do average fares and tips vary by borough?
	•	Do passengers tip more on longer trips?

4. Operational Efficiency
	•	What is the average trip speed across NYC?
	•	How does speed vary by time of day or borough?

5. Anomalies & Outliers
	•	What trips have impossible values (distance, time, speed, fare)?
	•	How can these be flagged and removed?

6. Distance vs. Duration Relationship
	•	How strongly are trip distance and duration correlated?

⸻

Data Cleaning (SQL)

Dataset:
bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022
(~35 million rows)

Cleaning process included:
	•	Removing trip_distance <= 0 or > 100 miles
	•	Removing trip_duration < 1 minute or > 180 minutes
	•	Ensuring passenger_count between 1 and 6
	•	Removing invalid fare_amounts
	•	Ensuring both datetimes are valid

Example:
  WHERE 
    trip_distance BETWEEN 0 AND 100
    AND timestamp_diff(dropoff_datetime, pickup_datetime, minute) BETWEEN 1 AND 180
    AND fare_amount BETWEEN 0.01 AND 300
    AND passenger_count BETWEEN 1 AND 6

Feature Engineering

To support deeper analysis, additional derived columns were created:
	•	trip_duration_min
	•	avg_speed_mph
	•	pickup_hour, pickup_weekday, pickup_month
	•	distance_bucket
	•	tip_percent
	•	Borough + zone names via JOIN with taxi_zone_geom

Example:
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  SAFE_DIVIDE(trip_distance, NULLIF(trip_duration_min, 0)) * 60 AS avg_speed_mph,
  CASE 
    WHEN trip_distance < 1 THEN '0–1 mi'
    WHEN trip_distance < 3 THEN '1–3 mi'
    WHEN trip_distance < 7 THEN '3–7 mi'
    ELSE '7+ mi'
  END AS distance_bucket
Key Findings

Demand
	•	Activity peaks in late afternoon / early evening (5–6 PM).
	•	Lowest demand occurs between 3–5 AM.
	•	Fridays and Saturdays maintain high late-night activity.

Geographic
	•	Manhattan dominates pickup volume.
	•	Airports in Queens contribute many high-distance trips.

Fare & Tips
	•	Tip percentage increases with distance.
	•	Manhattan trips show the highest tipping behavior.
	•	Short trips (under 1 mile) have noticeably low tips.

Efficiency
	•	Average citywide taxi speed is ~11–14 mph.
	•	Speeds drop significantly during the evening peak hours.

Outliers
	•	Less than 1% of rides are anomalies.
	•	Most anomalous records involve:
	•	durations < 1 minute
	•	zero-fare trips
	•	speeds > 60 mph

Correlation
	•	Distance and duration show a strong positive correlation (≈ 0.93).

⸻

Tools Used
	•	Google BigQuery
	•	Standard SQL
	•	GitHub for documentation
  
Repository Structure
  nyc-taxi-sql-analysis/
  │
  ├── README.md
  ├── queries/
  │   ├── cleaning.sql
  │   ├── enrichment.sql
  │   ├── demand_patterns.sql
  │   ├── geographic_trends.sql
  │   ├── fare_tip_behavior.sql
  │   ├── efficiency.sql
  │   └── correlation_outliers.sql
  └── docs/
      └── project_notes.md
Next Steps
	•	Build a small Tableau dashboard using a simpler dataset from the Google DA Certificate.
	•	Add more SQL analyses: YOY changes, airport-specific trends, and weekend vs weekday patterns.

⸻

Contact

Arthur Moreira — Aspiring Data Analyst
LinkedIn: https://www.linkedin.com/in/arthur-m-moreira/
GitHub: https://github.com/arthurmarzanmoreira
