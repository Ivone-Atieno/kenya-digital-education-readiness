-- MASTER VIEW: joins all 6 core tables on county

CREATE OR REPLACE VIEW county_master AS
SELECT
    p.county,
    -- School infrastructure (RQ1)
    pp.public_internet_pct   AS preprimary_public_internet_pct,
    pp.private_internet_pct  AS preprimary_private_internet_pct,
    pr.public_internet_pct   AS primary_public_internet_pct,
    pr.private_internet_pct  AS primary_private_internet_pct,
    sc.public_internet_pct   AS secondary_public_internet_pct,
    sc.private_internet_pct  AS secondary_private_internet_pct,
    -- Household context (RQ2)
    iu.internet_total_pct,
    iu.mobile_owned_total_pct,
    iu.computer_used_total_pct,
    -- Device deployment (RQ3)
    d.total_schools,
    d.installed_schools,
    d.recalculated_percentage_installed,
    d.ldd, d.tdd, d.projector,
    -- Population for normalization (RQ4)
    p.pop_total,
    p.hh_total
FROM population_census p
LEFT JOIN pre_primary_ict pp ON p.county = pp.county
LEFT JOIN primary_ict pr     ON p.county = pr.county
LEFT JOIN secondary_ict sc   ON p.county = sc.county
LEFT JOIN internet_usage iu  ON p.county = iu.county
LEFT JOIN dlp_installation d ON p.county = d.county;

-- Check should return 47
SELECT COUNT(*) FROM county_master;
