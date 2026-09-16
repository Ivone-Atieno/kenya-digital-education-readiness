-- Pre-Primary ICT Infrastructure
CREATE TABLE pre_primary_ict (
    county VARCHAR(50) PRIMARY KEY,
    public_computers_or_tablets INT,
    public_internet_pct DECIMAL(5,2),
    private_computers_or_tablets INT,
    private_internet_pct DECIMAL(5,2)
);

-- Primary ICT Infrastructure
CREATE TABLE primary_ict (
    county VARCHAR(50) PRIMARY KEY,
    public_computers_tablets INT,
    private_computers_tablets INT,
    public_internet_pct DECIMAL(5,2),
    private_internet_pct DECIMAL(5,2)
);

-- Secondary ICT Infrastructure
CREATE TABLE secondary_ict (
    county VARCHAR(50) PRIMARY KEY,
    public_computers INT,
    private_computers INT,
    public_internet_pct DECIMAL(5,2),
    private_internet_pct DECIMAL(6,2)  -- allows NULL for flagged >100% values
);

-- Household Internet/Computer/Mobile Usage
CREATE TABLE internet_usage (
    county VARCHAR(50) PRIMARY KEY,
    internet_total_pct DECIMAL(5,2),
    internet_male_pct DECIMAL(5,2),
    internet_female_pct DECIMAL(5,2),
    mobile_owned_total_pct DECIMAL(5,2),
    computer_used_total_pct DECIMAL(5,2),
    population_total BIGINT
);

-- DLP Device Installation
CREATE TABLE dlp_installation (
    county VARCHAR(50) PRIMARY KEY,
    total_schools INT,
    installed_schools INT,
    not_installed INT,
    percent_installed DECIMAL(6,2),
    ldd_hi INT,
    ldd_vi INT,
    embosser INT,
    ldd INT,
    tdd INT,
    dcswr INT,
    projector INT,
    recalculated_percentage_installed DECIMAL(6,2)
);

-- Population Census (county-level only)
CREATE TABLE population_census (
    county VARCHAR(50) PRIMARY KEY,
    pop_total BIGINT,
    pop_male BIGINT,
    pop_female BIGINT,
    hh_total INT,
    land_area_sqkm DECIMAL(10,2),
    density_per_sqkm DECIMAL(10,2)
);
