# Open the CSV file in read mode
with open('../../../resources/clean-data/main_rent_merge_2018ith_idh_wo_duplicates_2024_05_05.csv', 'r') as file:
    # Read the contents of the file
    contents = file.read()

# Replace all commas with periods in the contents
contents = contents.replace('.', ',')

# Open the CSV file in write mode
with open('../../../resources/clean-data/main_rent_merge_2018ith_idh_wo_duplicates_2024_05_05_out.csv', 'w') as file:
    # Write the modified contents back to the file
    file.write(contents)
