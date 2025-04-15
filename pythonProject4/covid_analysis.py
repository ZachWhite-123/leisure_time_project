import pandas as pd

file_path = "C:/Users/zachw/Downloads/USA Covid Data.xlsx"

pd.set_option('display.max_columns', None)

covid_df = pd.read_excel(file_path)

print(covid_df.head())



