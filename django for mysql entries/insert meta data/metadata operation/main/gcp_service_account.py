# pip install google-auth   <-- here

# Obtain a JSON key file for your GCP service account:

# Go to the GCP Console (console.cloud.google.com).
    # Open the menu and navigate to "IAM & Admin" > "Service Accounts".
    # Select your desired service account or create a new one.
    # Under the "Actions" column, click on the three dots and select "Create key".     <-- here
    # Choose the JSON key type and click "Create".
    # Save the JSON key file securely and note its path on your local machine.

# Set the GOOGLE_APPLICATION_CREDENTIALS environment variable:
    # Replace 'path/to/keyfile.json' in the following code with the path to your JSON key file.
    # Add this code to your Python script before authenticating:

import os

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'path/to/keyfile.json' # <-- here 

# check the object exist or not 
# ------------------------------ 

from google.cloud import storage

client = storage.Client()

def check_object_exists(bucket_name, object_name):
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    return blob.exists()

bucket_name = 'bucket_name'
object_name = 'object_name'

object_exists = check_object_exists(bucket_name, object_name)
if object_exists:
    print(f"The object '{object_name}' exists in the bucket '{bucket_name}'.")
else:
    print(f"The object '{object_name}' does not exist in the bucket '{bucket_name}'.")

# --------------------------------------------------------------------------------------------------------------------

# Transfer data from source to BQ:

from google.cloud import bigquery

# Set up the BigQuery client
client = bigquery.Client()

# Define the dataset and table information
project_id = "your-project-id"
dataset_id = "your-dataset-id"
table_id = "your-table-id"

# Set the path to your CSV file
csv_file = "/path/to/your/data.csv"

# Define the schema for the table
schema = [
    bigquery.SchemaField("column1", "STRING"),
    bigquery.SchemaField("column2", "INTEGER"),
    bigquery.SchemaField("column3", "FLOAT"),
    # Add more fields as needed
]

# Create the table reference
table_ref = client.dataset(dataset_id).table(table_id)

# Create the job configuration
job_config = bigquery.LoadJobConfig(schema=schema, skip_leading_rows=1)

# Start the load job
with open(csv_file, "rb") as source_file:
    job = client.load_table_from_file(source_file, table_ref, job_config=job_config)

# Wait for the job to complete
job.result()

# Check the job status
if job.state == "DONE":
    print("Data loaded successfully into BigQuery.")
else:
    print("Error loading data into BigQuery:", job.errors)

# -----------------------------------------------------------------------------------------------



 