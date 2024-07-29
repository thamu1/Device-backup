

"""
- "apis & services" -> library -> enable ga4(google analytic data) api
- we need to create a service account.
- download the private key json. while creating the account
- in analytic UI add your service id into that.
    => home - admin - account access management - add = (your service account mail id) - set as viewer (enough)
"""


import os
from datetime import datetime, timedelta, date
from typing import List
from google.analytics.data_v1beta import BetaAnalyticsDataClient, FilterExpression, FilterExpressionList, Filter 

from google.analytics.data_v1beta.types import (Dimension, Metric, DateRange, Metric, OrderBy, 
                                               FilterExpression, MetricAggregation, CohortSpec,MetricType)
from google.analytics.data_v1beta.types import RunRealtimeReportRequest,BatchRunReportsRequest, RunReportRequest, RunRealtimeReportRequest

from google.oauth2 import service_account
import pandas as pd


def report(recon_date:int, property_id:str, credentials_path:str, dimensions: List[str], metrics: List[Metric], row_limit:int=10000 ,quota_usage:bool=False):

    # from google.oauth2 import service_account
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    
    # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
    
    st_date = str(date.today() - timedelta(days=recon_date))
    en_date = str(date.today())
    
    # client = BetaAnalyticsDataClient(credentials=credentials) 
    client = BetaAnalyticsDataClient() 
    
    dimension_list = [Dimension(name=dim) for dim in dimensions]
    metrics_list = [Metric(name=m) for m in metrics]
    
    hostnames = [
        'www.thetruthaboutknives.com',
        'www.thetruthaboutguns.com',
        'rare.us',]
    # hostnames = ', '.join(hostnames)
    
    request = RunReportRequest(
        property=f"properties/{property_id}",
        dimensions=dimension_list,
        metrics=metrics_list,
        date_ranges=[DateRange(start_date=st_date, end_date=en_date)],
    )
    response = client.run_report(request)
    
    return(response)
    


res = report(
    property_id=331273219,
    credentials_path="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/service id json/ga_wom.json",
    # credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/prod/keystores/gcp/prod-ga4-wom-rpt/svc-prod-ga4-wom-rpt-c5c06cb656fd.json",
    recon_date=8,
    dimensions=["country", "city"], # ga:hostname, ga:country, ga:channelGrouping
    metrics=["activeUsers", "eventCount"], # ga:users, ga:pageviews, ga:sessions
    row_limit=100
)



# dim_head = res.dimension_headers
# mat_head = res.metric_headers
# rows = res.rows

# print(dim_head)

# df = pd.DataFrame()

    
