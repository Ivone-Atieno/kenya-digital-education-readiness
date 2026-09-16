"""
Kenya Digital Education Readiness Project
Connect to MySQL and pull the county_master view into pandas
"""
import pandas as pd
from sqlalchemy import create_engine

# --- Update these to match your local MySQL setup ---
USER = "root"
PASSWORD = "password"
HOST = "localhost"
DATABASE = "kenya_digital_education"

engine = create_engine(f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}/{DATABASE}")

# Pull the master view already built in SQL
df = pd.read_sql("SELECT * FROM county_master", con=engine)

print("Rows loaded:", len(df))
print(df.head())
