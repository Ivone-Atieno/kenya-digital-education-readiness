# Kenya Digital Education Readiness: Digital Infrastructure vs Educational Impact

## Problem Statement

Kenya's transition to the Competency-Based Education assumes learners and teachers have reasonable access to digital tools, devices, and connectivity - both at school and at home. Government programmes like the Digital Literacy Programme (DLP) and Kenya Digital Economy Acceleration Project (KDEAP) have invested significantly in device distribution and teacher training. This project examines whether that digital infrastructure is equitably distributed across Kenya's 47 counties, and whether the policy's digital expectations outpace what is actually available and actually used on the ground - particularly in marginalized, rural, and ASAL (arid and semi-arid land) counties.

## Research Questions

1. Which counties have poor school-level ICT infrastructure (computer/tablet and Internet) across pre-primary, primary and secondary school levels.
2. Do weak school infrastructure counties also exhibit low internet usage at the household level or is this gap only at the school level?
3. Are DLP devices reaching schools at a consistent rate across counties, or are some counties left behind in physical device rollout?
4. When normalized fairly (by school count, not raw population), which counties are most under-resourced?
5. Is there a consistent group of counties lagging across all dimensions (systemic disadvantage), or are gaps scattered and dimension-specific?
6. Does device installation actually translate into real usage — or is there a gap between policy delivery and ground reality?



## Data Sources

1. Basic Education Statistical Booklet 2020. 
https://www.education.go.ke/sites/default/files/Docs/The%20Basic%20Education%20Statistical%20Booklet%202020%20(1).pdf.
2. ICT Analytical Report Based on the 2023/24 Kenya Housing Survey.
https://www.ca.go.ke/sites/default/files/2025-08/ICT%20Analytical%20Report%20Based%20on%202023-2024%20Kenya%20Housing%20Survey_0.pdf.
3. Digital Literacy Programme Installation Summary.
https://cms.icta.go.ke/sites/default/files/2021-12/downloads_1.pdf.
4. 2019 Kenya Population and Housing Census.
https://data.humdata.org/dataset/kenya-population-per-county-from-census-report-2019.
5. 2024 National School Census (Pilot Report)- Used for contextual reference only; it focuses on 8 counties and was not included in the core analysis dataset.
https://www.knbs.or.ke/reports/2024-national-school-census-pilot-report
6. Kenya Schools GeoJSON (school locations) - Used for supplementary geographic information only; it was not part of the core county-level analysis.
https://datacatalog.worldbank.org/search/dataset/0038039/kenya-schools. 

## Methodology

**Pipeline**: Retrieved data using Python (camelot and pdfplumber) from rough pdf, excel and json files, followed by manual data cleaning within excel and then imported into MySQL tables as six relations tables plus one master merged view of the six relational tables, which was followed by the analytical reporting using Python (pandas and scipy), with the final results visualized in a single Power BI dashboard combined with custom DAX measure.

**Tools used**: Ms Excel, Python (pandas, camelot-py, pdfplumber, scipy, sqlalchemy), MySQL, Power BI Desktop (DAX).


## Data Quality Log

This project's source data required substantial cleaning. Rather than silently correcting or hiding issues, every anomaly below was investigated, verified against the original source document, and handled with a documented, defensible decision - preserving raw values alongside corrected ones wherever a value was excluded.

### 1. PDF table extraction misalignment (Basic Education Booklet)
There were initially discrepancies in columns identified between Primary and Secondary ICT by the automated extract (camelot-py) by way of empty spacer columns within the layout of the PDF. Raw column identifies from raw output were double-checked row-by-row with the source PDF (pages 114, 130, 143) before the column indices were finalized.

### 2. Impossible percentage values (>100%) - Secondary ICT table
Four counties in the secondary ICT table recorded an invalid, or physically impossible > 100 %, value for private_internet_pct. They are, Tana River, Isiolo, Turkana, and Siaya with values recorded at 150%, 166.7%, 150%, and 200% respectively. These values were confirmed on comparison with the primary source, page 143, and deemed non-artifact based on a hypothesis of decimal shifting - (value/10). It was then decided that each row which had >100% private internet percentage data (page 143) would be rejected (Nullified) and kept the original extracted (raw data) in a separate other column where would be stored, explanation of invalidity would be kept.

### 3. Impossible installed-school counts - DLP Installation data
Four counties (Kisii, Mandera, Marsabit, Murang'a) show `installed_schools` exceeding `total_schools` - logically impossible, confirmed present in the original ICTA report itself. It was decided to store the original percentage installed and added a recalculated percentage installed based on (installed/total), and affected counties flagged (not correcting, as the true values could not be determined from the available data).

### 4. Text-as-number import failures (MySQL)
A literal `"N/A"` string in a percentage field, rejected by a `DECIMAL` column type, again silently dropping 4 rows. Both diagnosed by comparing `SELECT COUNT(*)` against expected row counts, then confirmed via raw file inspection. It was resolved that the column widths corrected; true NULLs inserted directly via `INSERT` once root cause was confirmed.

### 5. County name inconsistency across all six source files
There was varied spelling/casing/punctuation in how the same 47 counties are presented in each file (ELGEYO/MARAKWET, Elgeyo-Marakwet, Elgeyo Marakwet, etc.; MURANG'A, Murang'a; HOMABAY, Homa Bay). It was decided a single canonical list of 47 counties should be created and implemented for every file via lookup/VLOOKUP prior to each join.

### 6. Hierarchical, multi-level source file (2019 Census)
The population census file mixed National, County, and Sub-county rows in a single column, distinguished only by indentation (leading whitespace) - not a structured "level" field. It was resolved that the indentation-based formula added to tag each row's level; only the 47 County-level rows retained for the main analysis dataset; sub-county detail preserved separately, not discarded.

### 7. Incorrect coordinate reference system (Schools GeoJSON)
The file's native `geometry.coordinates` field was in a non-standard, unidentified projected coordinate system (values in the millions, not valid latitude/longitude degrees). It was decided to adopt the proper X-Coordinates / Y-Coordinates properties field and have the already known values for Kenya boundaries (33.9-41.9E, -4.7-5.3N).

### 8. Duplicate/inconsistent county names in Schools GeoJSON
In the school-location file pre 2013 administrative district names were used for Nairobi (NAIROBI, NAIROBI NORTH, NAIROBI SOUTH, NAIROBI WEST) instead of the current all-inclusive "Nairobi City" county; and hyphenation style normalized in a district, additionally ~30 row with blank entries. The decisions on standardization were to combine all Nairobi variants into a single entity "Nairobi City"; hyphen style normalized; blank rows deleted, verify the final file with exactly 47 counties.

### 9. Mismatched school-count denominators considered and rejected
Considered using the Schools GeoJSON (2016 Ministry of Education data) to recalculate DLP's `total_schools` denominator. The GeoJSON is dated 2016 and therefore rejected, while DLP installation reflects 2019–2021 - mixing a ~3-5 year-old school count with a differently-dated installation figure would introduce a timing mismatch rather than improve accuracy. DLP's own internally-consistent `total_schools` figure was retained instead.


## Key Findings

1. Public vs private school internet access are substantially different across the country (t-test, p<0.00000001, d=2.03) with means 22.9% for public, 39.9% for private school users.
2. Household access is weakly but not strongly correlated with school access (r=0.517, household context explaining only a quarter of variance in school connectivity)
3. Device installation (~99%) is very poorly correlated with usage of actual computers on school premise (r=-0.13, p not signficant). Central conclusion about policy vs ground reality this project aimed to uncover. Shows single digit usage rates while installations hover near 100% in example counties like Wajir, Tana River.
4. ASAL classification does not predict school connectivity significantly (p=.62) - official categorizations are real but don't correlate well with disadvantage which we operationalize here in this way.
5. An important and persistent trend with a gender gap on all but 2 of 47 countries, is found for this variable (mean difference of 5.95, p<0.00000001)
6. Only Tharaka Nithi and Samburu appear disadvantage in more than 3 of the 4 dimensions studied concurrently-disadvantage appears to be dimension specific, not the norm on the county level.

## Limitations

1. Data sources comprise three non simultaneously comparable periods of time: 2019, 2020 and 2023/2024.
2. The data on the 2024 National School Census covers just eight counties (pilot only) and are only used for contextualization.
3. Population/enrollment data which is specified only for the school age is not readily available; use data related to "equity indices per school" (not per learner) as a proxy since it's the best available.
4. Household internet usage / ownership is a survey based estimation (2023/24 Kenya Housing Survey) and not a complete census, therefore has the usual sampling variability.
