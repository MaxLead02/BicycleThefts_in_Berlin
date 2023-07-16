import csv
from opencage.geocoder import OpenCageGeocode

# OpenCageData API key
api_key = "you_API_key_here"

# Function to retrieve latitude and longitude for a given address
def get_lat_lng(address):
    print('Retrieving latitude and longitude for: {}'.format(address))
    geocoder = OpenCageGeocode(api_key)
    result = geocoder.geocode(address)
    if result and len(result):
        location = result[0]['geometry']
        latitude = location['lat']
        longitude = location['lng']
        print('Latitude and longitude for {} are: {}, {}'.format(address, latitude, longitude))
        return latitude, longitude
    else:
        return None, None

# Path to your input CSV file
input_file = 'lor_planungsraeume_2021.csv'

# Path to your output CSV file
output_file = 'lor_plan_rm_with_coord.csv'

print('Adding latitude and longitude to the dataset...')
# Open input and output files
with open(input_file, 'r') as csv_input, open(output_file, 'w', newline='') as csv_output:
    reader = csv.reader(csv_input)
    writer = csv.writer(csv_output)
    
    # Read the header row
    header = next(reader)
    
    # Add 'latitude' and 'longitude' to the header
    header.extend(['latitude', 'longitude'])
    writer.writerow(header)
    
    # Iterate over the rows in the input file
    for count, row in enumerate(reader):
        
        # Print status every 100 rows
        if count % 100 == 0:
            print('Processing row {}'.format(count))

        address = row[12]  
        
        # Retrieve latitude and longitude for the address
        latitude, longitude = get_lat_lng(address)
        
        # Append latitude and longitude to the row
        row.extend([latitude, longitude])
        
        # Write the updated row to the output file
        writer.writerow(row)

print("Latitude and longitude added to the dataset.")
