/** Gender gap in internet usage -- does the male/female gap
widen or narrow in counties with lower overall internet access?**/
SELECT
    county,
    internet_male_pct,
    internet_female_pct,
    ROUND(internet_male_pct - internet_female_pct, 2) AS gender_gap_points,
    internet_total_pct,
    RANK() OVER (ORDER BY (internet_male_pct - internet_female_pct) DESC) AS gender_gap_rank
FROM internet_usage
ORDER BY gender_gap_points DESC
LIMIT 10;



-- Public vs Private school gap -- where is the divide between public and private school internet access largest?
SELECT
    county,
    primary_public_internet_pct,
    primary_private_internet_pct,
    ROUND(primary_private_internet_pct - primary_public_internet_pct, 2) AS private_advantage_points
FROM county_master
WHERE primary_private_internet_pct IS NOT NULL
ORDER BY private_advantage_points DESC
LIMIT 10;


-- FINDING 3: Correlation check -- does higher population density relate to better school internet access?
WITH density_buckets AS (
    SELECT
        county,
        pop_total,
        (preprimary_public_internet_pct+primary_public_internet_pct+secondary_public_internet_pct)/3 AS avg_school_internet,
        NTILE(3) OVER (ORDER BY pop_total DESC) AS density_tier  -- 1 = most populous, 3 = least
    FROM county_master
)
SELECT
    density_tier,
    COUNT(*) AS num_counties,
    ROUND(AVG(avg_school_internet), 2) AS avg_school_internet_pct
FROM density_buckets
GROUP BY density_tier
ORDER BY density_tier;


-- "Overachiever" counties 
SELECT
    county,
    pop_total,
    (preprimary_public_internet_pct+primary_public_internet_pct+secondary_public_internet_pct)/3 AS avg_school_internet,
    RANK() OVER (ORDER BY pop_total ASC) AS smallest_population_rank,
    RANK() OVER (ORDER BY (preprimary_public_internet_pct+primary_public_internet_pct+secondary_public_internet_pct) DESC) AS school_internet_rank
FROM county_master
HAVING smallest_population_rank <= 15 AND school_internet_rank <= 15;



/**Mobile ownership vs internet usage divergence -- counties where people own phones but don't use the internet (affordability /
literacy barrier rather than access barrier)**/

SELECT
    county,
    mobile_owned_total_pct,
    internet_total_pct,
    ROUND(mobile_owned_total_pct - internet_total_pct, 2) AS ownership_minus_usage_gap
FROM county_master
ORDER BY ownership_minus_usage_gap DESC
LIMIT 10;


