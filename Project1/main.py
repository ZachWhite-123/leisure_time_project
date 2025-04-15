import pandas as pd

file_path = "C:/Users/zachw/Downloads/archive/StudentPerformanceFactors.xlsx"

pd.set_option('display.max_columns', None)

scores_df = pd.read_excel(file_path)

print(scores_df.head())

scores_df.info()

print(scores_df.describe())

print(scores_df.shape)

scores_df_subset = scores_df[scores_df.columns[:5]]
print(scores_df_subset.columns)

print(scores_df.columns)

## get last 5 columns
scores_df_subset_two = scores_df[scores_df.columns[-5:]]
print(scores_df_subset_two.columns)

print("\ninteger columns:")
## subset only the columns of type integer
print(scores_df.select_dtypes("int").columns)

print("\nFor the second person in the dataset, find their test score")
print(scores_df.iloc[1, -1])

print("\n Subset the df into the first 5 rows and the last 5 columns:")
print(scores_df.iloc[:5, -5:])

print("\nConvert the 5th row to a dataframe: ")
print(scores_df.iloc[[4]])

print("\nFilter the dataframe to all rows and first and last columns: ")
print(scores_df.iloc[:, [1, -1]])

print("\nFilter the dataframe to contain only rows with females: \n")
print(scores_df.loc[scores_df["Gender"] == "Female"])

print("Filter the dataframe with only males with less than 8 hour of sleep a night \n")
print(scores_df.loc[(scores_df["Gender"] == "Male") & (scores_df["Sleep_Hours"] < 8)])

print("Filter the dataframe to be only public schools. Use a tilda.")
print(scores_df.loc[~(scores_df["School_Type"] == "Private")])

print("Compare the mean number of sleep hours for both men and women in the df \n")
male_df = scores_df.loc[scores_df["Gender"] == "Male"]
print(male_df["Sleep_Hours"].mean())

female_df = scores_df.loc[scores_df["Gender"] == "Female"]
print(female_df["Sleep_Hours"].mean())

print("Use an agg method with a dictionary to get the min, max of sleep, the mean physical activity, and the median exam score\n")
print(scores_df[["Sleep_Hours", "Physical_Activity", "Exam_Score"]].agg(
    {"Sleep_Hours" : ["min", "max"],
     "Physical_Activity" : ["mean"],
     "Exam_Score" : ["median"]}
))

print("\nUse value_counts fxn to find the count of each level in parent_education_level: ")
print(scores_df["Parental_Education_Level"].value_counts())
print("^ Put normalize as true above to get proportions. Sort=true sorts. \n")


print("Find the proportion of each unique teacher quality & school type pair: \n")
print(scores_df[["School_Type", "Teacher_Quality"]].value_counts(normalize=True, sort=True).reset_index())


print("\nGroup by parental involvement, then find the average exam score for each level of parental involvement: \n")
print(scores_df.groupby("Parental_Involvement")[["Exam_Score"]].mean())

print("\n Use the agg method to group by access to resources, then find the min, max, mean for both hours studied and sleep hours: \n")
print(scores_df.groupby("Access_to_Resources")[["Hours_Studied", "Sleep_Hours"]].agg(["mean", "min", "max"]))


print("\nMake a new column titled exam score / hours studied: \n")
scores_df["Scores Per Study"] = scores_df["Exam_Score"] / scores_df["Sleep_Hours"]
print(scores_df)