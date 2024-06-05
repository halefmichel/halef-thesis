# Open the CSV file in read mode
with open('/Users/karimmbk/Documents/halef-thesis/social-indicators/indicators-SP.csv', 'r') as file:
    # Read the contents of the file
    contents = file.read()

# Replace all commas with periods in the contents
contents = contents.replace(',', '.')

# Open the CSV file in write mode
with open('/Users/karimmbk/Documents/halef-thesis/social-indicators/indicators-SP(1).csv', 'w') as file:
    # Write the modified contents back to the file
    file.write(contents)
