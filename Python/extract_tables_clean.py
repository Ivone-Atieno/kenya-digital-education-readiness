"""
Kenya Digital Education Readiness Project
Extracts county-level ICT infrastructure tables (computers/tablets,
internet access) from the Ministry of Education's Basic Education
Statistical Booklet 2020 (PDF), for Pre-Primary, Primary, and
Secondary school levels.
"""
import camelot
import pandas as pd

SOURCE = "basic_education_booklet_2020.pdf"  # update to your local filename


def clean_county_table(df: pd.DataFrame, level_name: str) -> pd.DataFrame:
    """
    Drop title/header noise rows from a raw camelot-extracted table,
    keeping only rows where the first column looks like a real county
    name, and tag each row with its education level.
    """
    df = df.copy()
    df.columns = range(df.shape[1])
    mask = df[0].astype(str).str.strip().str.match(r"^[A-Za-z][A-Za-z\s’'\.]+$")
    data = df[mask].copy()
    data = data[data[0].str.strip() != "County"]
    data.insert(0, "education_level", level_name)
    return data


# --- Pre-Primary: Table I.10, page 114---
t1 = camelot.read_pdf(SOURCE, pages="114", flavor="stream")[0].df
pre_primary = clean_county_table(t1, "Pre-Primary")
pre_primary = pre_primary.iloc[:, [0, 1, 2, 3, 4, 5]]
pre_primary.columns = [
    "education_level", "county", "public_computers_tablets", "public_internet_pct",
    "private_computers_tablets", "private_internet_pct",
]

# --- Primary: Table II.16, page 130---
t2 = camelot.read_pdf(SOURCE, pages="130", flavor="stream")[0].df
primary = clean_county_table(t2, "Primary")
primary = primary.iloc[:, [0, 1, 2, 3, 5, 8]]
primary.columns = [
    "education_level", "county", "public_computers_tablets", "private_computers_tablets",
    "public_internet_pct", "private_internet_pct",
]

# --- Secondary: Table III.13, page 143 ---
t3 = camelot.read_pdf(SOURCE, pages="143", flavor="stream")[0].df
secondary = clean_county_table(t3, "Secondary")
secondary = secondary.iloc[:, [0, 1, 2, 3, 4, 5, 6, 8]]
secondary.columns = [
    "education_level", "county", "public_computers", "private_computers", "all_computers",
    "public_internet_pct", "private_internet_pct", "all_internet_pct",
]

pre_primary.to_csv("pre_primary_ict.csv", index=False)
primary.to_csv("primary_ict.csv", index=False)
secondary.to_csv("secondary_ict.csv", index=False)

print("Pre-Primary rows:", len(pre_primary))
print("Primary rows:", len(primary))
print("Secondary rows:", len(secondary))
