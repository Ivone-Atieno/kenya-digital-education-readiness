"""
Statistical analysis
- Correlation between school internet access and household internet access
- Hypothesis test: do ASAL/marginalized counties differ significantly
  from the rest on key metrics?
"""
import pandas as pd
from scipy import stats

# df = pd.read_sql(...)

# --- Compute composite school internet score ---
df['avg_school_internet'] = (
    df['preprimary_public_internet_pct'] +
    df['primary_public_internet_pct'] +
    df['secondary_public_internet_pct']
) / 3

# --- Correlation: school internet vs household internet ---
corr, p_value = stats.pearsonr(df['avg_school_internet'], df['internet_total_pct'])
print(f"Correlation (school vs household internet): r = {corr:.3f}, p = {p_value:.4f}")
# r close to 0 = weak relationship
# r close to 1 = strong relationship

# --- Hypothesis test: ASAL counties vs non ASAL ---
ASAL_COUNTIES = [
    "Turkana","Marsabit","Samburu","Isiolo","Mandera","Wajir","Garissa",
    "Tana River","Lamu","Kajiado","Kilifi","Kwale","Taita Taveta",
    "West Pokot","Baringo","Laikipia","Narok","Kitui","Makueni",
    "Meru","Tharaka Nithi","Embu","Kajiado"
]
df['is_asal'] = df['county'].isin(ASAL_COUNTIES)

asal_group = df[df['is_asal']]['avg_school_internet']
non_asal_group = df[~df['is_asal']]['avg_school_internet']

t_stat, p_val = stats.ttest_ind(asal_group, non_asal_group, equal_var=False)
print(f"\nASAL vs Non-ASAL school internet access:")
print(f"ASAL mean: {asal_group.mean():.2f}%  |  Non-ASAL mean: {non_asal_group.mean():.2f}%")
print(f"t-statistic = {t_stat:.3f}, p-value = {p_val:.4f}")
print("Statistically significant difference" if p_val < 0.05 else "No statistically significant difference")
