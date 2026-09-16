-- pivot style view comparing all 3 education levels side by side

WITH level_pivot AS (
    SELECT
        county,
        MAX(preprimary_public_internet_pct)  AS preprimary_pct,
        MAX(primary_public_internet_pct)     AS primary_pct,
        MAX(secondary_public_internet_pct)   AS secondary_pct
    FROM county_master
    GROUP BY county
)
SELECT
    county,
    preprimary_pct,
    primary_pct,
    secondary_pct,
    ROUND((preprimary_pct + primary_pct + secondary_pct) / 3, 2) AS avg_across_levels,
    -- window function: rank each county against all others
    RANK() OVER (ORDER BY (preprimary_pct + primary_pct + secondary_pct) ASC) AS national_rank_worst_first,
    -- window function: which quartile does this county fall into?
    NTILE(4) OVER (ORDER BY (preprimary_pct + primary_pct + secondary_pct) ASC) AS quartile
FROM level_pivot
ORDER BY avg_across_levels ASC;


-- School vs household internet gap
SELECT
    county,
    avg_school_internet,
    internet_total_pct AS household_internet,
    ROUND(internet_total_pct - avg_school_internet, 2) AS household_minus_school_gap,
    -- window function: national average school internet, repeated on every row for comparison
    ROUND(AVG(avg_school_internet) OVER (), 2) AS national_avg_school_internet,
    -- flag counties below national average using a CASE + subquery
    CASE
        WHEN avg_school_internet < (SELECT AVG(avg_school_internet) FROM (
            SELECT (preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct)/3 AS avg_school_internet
            FROM county_master) sub)
        THEN 'BELOW NATIONAL AVG'
        ELSE 'AT OR ABOVE AVG'
    END AS school_infra_flag
FROM (
    SELECT county, internet_total_pct,
           (preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct)/3 AS avg_school_internet
    FROM county_master
) AS base
ORDER BY household_minus_school_gap DESC;



-- Device installation ranked with LAG() to show how
-- much worse each county is vs the county ranked just above it
SELECT
    county,
    recalculated_percentage_installed,
    RANK() OVER (ORDER BY recalculated_percentage_installed ASC) AS install_rank,
    LAG(recalculated_percentage_installed) OVER (ORDER BY recalculated_percentage_installed ASC) AS pct_of_next_better_county,
    ROUND(recalculated_percentage_installed - LAG(recalculated_percentage_installed) OVER (ORDER BY recalculated_percentage_installed ASC), 2) AS gap_from_next_county
FROM county_master
ORDER BY install_rank ASC
LIMIT 15;



--Systemic vs scattered gaps -- counties in bottom
-- quartile across MULTIPLE dimensions simultaneously (multi-CTE)
WITH school_q AS (
    SELECT county, NTILE(4) OVER (ORDER BY (preprimary_public_internet_pct+primary_public_internet_pct+secondary_public_internet_pct) ASC) AS q
    FROM county_master
),
household_q AS (
    SELECT county, NTILE(4) OVER (ORDER BY internet_total_pct ASC) AS q
    FROM county_master
),
device_q AS (
    SELECT county, NTILE(4) OVER (ORDER BY recalculated_percentage_installed ASC) AS q
    FROM county_master
),
population_q AS (
    SELECT county, NTILE(4) OVER (ORDER BY (ldd/pop_total) ASC) AS q
    FROM county_master WHERE pop_total > 0
)
SELECT
    s.county,
    s.q AS school_quartile,
    h.q AS household_quartile,
    d.q AS device_quartile,
    p.q AS equity_quartile,
    (CASE WHEN s.q=1 THEN 1 ELSE 0 END +
     CASE WHEN h.q=1 THEN 1 ELSE 0 END +
     CASE WHEN d.q=1 THEN 1 ELSE 0 END +
     CASE WHEN p.q=1 THEN 1 ELSE 0 END) AS bottom_quartile_count
FROM school_q s
JOIN household_q h ON s.county = h.county
JOIN device_q d ON s.county = d.county
JOIN population_q p ON s.county = p.county
HAVING bottom_quartile_count >= 3
ORDER BY bottom_quartile_count DESC;


-- Counties where device installation is high but actual usage indicators are low 
SELECT
    county,
    recalculated_percentage_installed AS device_install_pct,
    computer_used_total_pct AS household_computer_use_pct,
    ROUND(recalculated_percentage_installed - computer_used_total_pct, 2) AS install_minus_usage_gap
FROM county_master
WHERE recalculated_percentage_installed > 95   -- near-universal installation
ORDER BY install_minus_usage_gap DESC
LIMIT 10;

