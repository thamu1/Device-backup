Description:
    This Python script assists in generating an HTML (Hypertext Markup Language) document for the Analytic HUB description, focusing on a specific subject area, using a basic template.

Requirements to Run the Python Script:
    - Python
    - pandas library
    - os library
    - Input file in CSV format containing object details
    - Location to store the resulting HTML file

Code Description:
    This script primarily operates through file operations in append mode. It creates an HTML template and populates it with object details, which are then saved in the specified output HTML file in the provided location.

CSV File Record Order:
    The CSV file should adhere to the following record order:

    1. S.No
    2. Object_Name
    3. Description
    4. Primarykey
    5. SourceSystem
    6. SourceLanding
    7. Frequency
    8. RefreshTime
    9. AvgRecord
    10. AvgDatasize
    11. DataRetention
    12. PartitionColumn
    13. ClusteringColumn
    14. Support
    15. Status

    For more information, please refer to the sample CSV file included in the same directory as the script.