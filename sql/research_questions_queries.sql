-- Rank counties by average internet access across all 3 school levels (public school)
SELECT
    county,
    preprimary_public_internet_pct,
    primary_public_internet_pct,
    secondary_public_internet_pct,
    ROUND((preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct) / 3, 2) AS avg_public_internet_pct
FROM county_master
ORDER BY avg_public_internet_pct ASC
LIMIT 10;


-- Compare school infrastructure rank vs household internet rank side by side
SELECT
    county,
    ROUND((preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct) / 3, 2) AS avg_school_internet_pct,
    internet_total_pct AS household_internet_pct,
    ROUND(internet_total_pct - (preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct) / 3, 2) AS household_minus_school_gap
FROM county_master
ORDER BY avg_school_internet_pct ASC
LIMIT 15;
-- A large positive gap = household internet is much better than school internet (school-specific problem)
-- A small/negative gap = both are weak together (broader connectivity problem)



-- Physical device rollouts
SELECT
    county,
    total_schools,
    installed_schools,
    recalculated_percentage_installed,
    RANK() OVER (ORDER BY recalculated_percentage_installed ASC) AS install_rank_lowest_first
FROM county_master
ORDER BY recalculated_percentage_installed ASC
LIMIT 10;


-- LDD per-school
SELECT
    county,
    ldd AS learner_digital_devices_tablets,
    total_schools,
    ROUND(ldd / total_schools, 2) AS ldd_per_school,
    RANK() OVER (ORDER BY (ldd / total_schools) ASC) AS equity_rank_worst_first
FROM county_master
WHERE total_schools > 0
ORDER BY ldd_per_school ASC
LIMIT 10;


--Counties lagging on all three  dimensions (systemic pattern)
WITH school_rank AS (
    SELECT county, RANK() OVER (ORDER BY (preprimary_public_internet_pct + primary_public_internet_pct + secondary_public_internet_pct)/3 ASC) AS r
    FROM county_master
),
household_rank AS (
    SELECT county, RANK() OVER (ORDER BY internet_total_pct ASC) AS r
    FROM county_master
),
device_rank AS (
    SELECT county, RANK() OVER (ORDER BY recalculated_percentage_installed ASC) AS r
    FROM county_master
)
SELECT
    s.county,
    s.r AS school_infra_rank,
    h.r AS household_internet_rank,
    d.r AS device_install_rank
FROM school_rank s
JOIN household_rank h ON s.county = h.county
JOIN device_rank d ON s.county = d.county
WHERE s.r <= 10 AND h.r <= 10 AND d.r <= 10;

