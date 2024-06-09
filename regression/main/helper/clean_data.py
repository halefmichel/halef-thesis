# Open the CSV file in read mode
with open('/Users/karimmbk/Documents/halef-thesis/web-scraper/resources/clean-data/rent_2018_2021.csv', 'r') as file:
    # Read the contents of the file
    contents = file.read()

# Replace all commas with periods in the contents
contents = contents.replace(',', '.')

# Open the CSV file in write mode
with open('/Users/karimmbk/Documents/halef-thesis/web-scraper/resources/clean-data/rent_2018_2021_out.csv', 'w') as file:
    # Write the modified contents back to the file
    file.write(contents)
